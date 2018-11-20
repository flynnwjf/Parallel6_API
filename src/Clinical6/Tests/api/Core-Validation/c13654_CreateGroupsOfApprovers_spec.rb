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
  let(:testname) { "consent_approver_groups_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d") }


  it 'C13654 API Client should be able to create groups of approvers', test_id: 'C13654' do
    test_rail_expected_steps(4)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/consent/approver_groups
    test_rail_expected_result(1, "It returns a 201 response and details of the approver group.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/consent/approver_groups
    approver_groups_create = V3::Consent::ApproverGroups::Create.new(super_user_session.token, user_email, base_url, name)
    resp_code = approver_groups_create.response.code
    resp_json = JSON.parse(approver_groups_create.response.body)
    test_rail_result(1, "approver_groups_create header: #{approver_groups_create.response.headers}")
    test_rail_result(1, "approver_groups_create body: #{approver_groups_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating approver groups response code: #{resp_code}", "pass")
    expect(resp_json.dig("data", "type")).to eq "consent__approver_groups"
    expect(resp_json.dig("data", "attributes", "name")).to eq name
    test_rail_result(1, "created approver group name in response: #{name}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/consent/approver_groups with invalid parameters
    test_rail_expected_result(2, "It returns a 422 response with the error message detail can't be blank")
    #POST request on {{protocol}}{{url}}/v3/consent/approver_groups with invalid parameters
    approver_groups_create = V3::Consent::ApproverGroups::Create.new(super_user_session.token, user_email, base_url, "")
    resp_code = approver_groups_create.response.code
    test_rail_result(2, "approver_groups_create header: #{approver_groups_create.response.headers}")
    test_rail_result(2, "approver_groups_create body: #{approver_groups_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating approver groups response code: #{resp_code}", "pass")

    #Step3 The user makes a POST request on {{protocol}}{{url}}/v3/consent/approver_groups with invalid parameters
    test_rail_expected_result(2, "It returns a 422 response with the error message detail has already been taken")
    #POST request on {{protocol}}{{url}}/v3/consent/approver_groups with invalid parameters
    approver_groups_create = V3::Consent::ApproverGroups::Create.new(super_user_session.token, user_email, base_url, name)
    resp_code = approver_groups_create.response.code
    test_rail_result(3, "approver_groups_create header: #{approver_groups_create.response.headers}")
    test_rail_result(3, "approver_groups_create body: #{approver_groups_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(3, "creating approver groups response code: #{resp_code}", "pass")

    #Step4 The unauthorized user makes a post request on {{protocol}}{{url}}/v3/consent/approver_groups
    test_rail_expected_result(4, "It returns a 403response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/consent/approver_groups
    approver_groups_create = V3::Consent::ApproverGroups::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, name)
    resp_code = approver_groups_create.response.code
    test_rail_result(4, "approver_groups_create header: #{approver_groups_create.response.headers}")
    test_rail_result(4, "approver_groups_create body: #{approver_groups_create.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(4, "creating approver groups response code: #{resp_code}", "pass")
  end

end

