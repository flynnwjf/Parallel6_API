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
  let(:testname) { "consent_approver_groups_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C14082 API Client should be able to retrieve one Approver Group by ID', test_id: 'C14082' do
    test_rail_expected_steps(3)

    #Step1 Make a Get request on {{protocol}}{{url}}v3/consent/approver_groups/{{id}}
    test_rail_expected_result(1, "It returns a 200 response and only the details of the approver group ID.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    group_id = V3::Consent::ApproverGroups::Index.new(super_user_session.token, user_email, base_url).id
    consent_approver_groups_show = V3::Consent::ApproverGroups::Show.new(super_user_session.token, user_email, base_url, group_id)
    test_rail_result(1, "consent_approver_groups_show body header: #{consent_approver_groups_show.response.headers}")
    test_rail_result(1, "consent_approver_groups_show body: #{consent_approver_groups_show.response.body}")
    resp_code = consent_approver_groups_show.response.code
    resp_json = JSON.parse(consent_approver_groups_show.response.body)
    expect(resp_code).to eq 200
    test_rail_result(1, "consent_approver_groups_show response code: #{resp_code}", "pass")
    expect(resp_json.dig("data","id")).to eq group_id
    test_rail_result(1, "approver group id in response: #{group_id}", "pass")

    #Step2 Make a Get request on {{protocol}}{{url}}v3/consent/approver_groups/{{id}} with invalid id
    test_rail_expected_result(2, "It returns a 404 response with the error message detail Couldn't find Consent::ApproverGroup with 'id'={{id}")
    #Get request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    invalid_id = test_data["invalid_id"]
    consent_approver_groups_show = V3::Consent::ApproverGroups::Show.new(super_user_session.token, user_email, base_url, invalid_id)
    test_rail_result(2, "consent_approver_groups_show body header: #{consent_approver_groups_show.response.headers}")
    test_rail_result(2, "consent_approver_groups_show body: #{consent_approver_groups_show.response.body}")
    resp_code = consent_approver_groups_show.response.code
    expect(resp_code).to eq 404
    test_rail_result(2, "consent_approver_groups_show response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a Get request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    test_rail_expected_result(3, "It returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/consent/approver_groups/{{id}}
    consent_approver_groups_show = V3::Consent::ApproverGroups::Show.new(unauthorized_user_session.token, unauthorized_user_email, base_url, group_id)
    test_rail_result(3, "consent_approver_groups_show body header: #{consent_approver_groups_show.response.headers}")
    test_rail_result(3, "consent_approver_groups_show body: #{consent_approver_groups_show.response.body}")
    resp_code = consent_approver_groups_show.response.code
    expect(resp_code).to eq 403
    test_rail_result(3, "consent_approver_groups_show response code: #{resp_code}", "pass")
  end

end


