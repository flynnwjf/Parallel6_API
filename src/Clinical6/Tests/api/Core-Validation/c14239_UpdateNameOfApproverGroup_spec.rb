require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:testname) { "consent_approver_groups_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test-" + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C14239 API Client should be able to update the name of an Approver Group', test_id: 'C14239' do
    test_rail_expected_steps(4)

    #Step1 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    test_rail_expected_result(1, "It returns a 200 response and displays the updated name attribute in the response.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Patch request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    #The last group in group list
    group_id = V3::Consent::ApproverGroups::Index.new(super_user_session.token, user_email, base_url).id
    consent_approver_groups_update = V3::Consent::ApproverGroups::Update.new(super_user_session.token, user_email, base_url, group_id, name)
    resp_code = consent_approver_groups_update.response.code
    resp_json = JSON.parse(consent_approver_groups_update.response.body)
    test_rail_result(1, "consent_approver_groups_update header: #{consent_approver_groups_update.response.headers}")
    test_rail_result(1, "consent_approver_groups_update body: #{consent_approver_groups_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "updating consent approver groups response code: #{resp_code}", "pass")
    expect(resp_json.dig("data", "attributes", "name")).to eq name
    test_rail_result(1, "updating consent approver groups name in response: #{name}", "pass")

    #Step2 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}} with invalid id
    test_rail_expected_result(2, "Api testing tool returns a 404 response.")
    #Patch request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    invalid_id = test_data["invalid_id"]
    consent_approver_groups_update = V3::Consent::ApproverGroups::Update.new(super_user_session.token, user_email, base_url, invalid_id, name)
    resp_code = consent_approver_groups_update.response.code
    test_rail_result(2, "consent_approver_groups_update header: #{consent_approver_groups_update.response.headers}")
    test_rail_result(2, "consent_approver_groups_update body: #{consent_approver_groups_update.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "updating consent approver groups response code: #{resp_code}", "pass")

    #Step3 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}} with same name
    test_rail_expected_result(3, "The result returns a 422 response with an error message detail has already been taken.")
    #Patch request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    #The name of first group in group list
    existing_name = JSON.parse(V3::Consent::ApproverGroups::Index.new(super_user_session.token, user_email, base_url).response.body).dig("data", 0, "attributes", "name")
    consent_approver_groups_update = V3::Consent::ApproverGroups::Update.new(super_user_session.token, user_email, base_url, group_id, existing_name)
    resp_code = consent_approver_groups_update.response.code
    test_rail_result(3, "consent_approver_groups_update header: #{consent_approver_groups_update.response.headers}")
    test_rail_result(3, "consent_approver_groups_update body: #{consent_approver_groups_update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(3, "updating consent approver groups response code: #{resp_code}", "pass")

    #Step4 The unauthorized user makes a Patch request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    test_rail_expected_result(4, "It returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Patch request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    consent_approver_groups_update = V3::Consent::ApproverGroups::Update.new(unauthorized_user_session.token, unauthorized_user_email, base_url, group_id, name)
    resp_code = consent_approver_groups_update.response.code
    test_rail_result(4, "consent_approver_groups_update header: #{consent_approver_groups_update.response.headers}")
    test_rail_result(4, "consent_approver_groups_update body: #{consent_approver_groups_update.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(4, "updating consent approver groups response code: #{resp_code}", "pass")
  end

end

