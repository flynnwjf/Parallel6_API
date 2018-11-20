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
  let(:testname) { "consent_forms_approvergroupassignments_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C13660 API Client should be able to retrieve the ApproverGroupAssignment for a specific FormVersion', test_id: 'C13660' do
    test_rail_expected_steps(3)

    #Step1 Make a Get request on {{protocol}}{{url}}/v3/consent/form_versions/:form_version_id/consent/approver_group_assignments
    test_rail_expected_result(1, "The user should see that Consent Approver Group Assignment displayed in the repose and 200 OK status")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/consent/form_versions/:form_version_id/consent/approver_group_assignments
    formversion_id = V3::Consent::FormVersions::Index.new(super_user_session.token, user_email, base_url).id
    approvergroupassignments_list = V3::Consent::Forms::ApproverGroupAssignments::List.new(super_user_session.token, user_email, base_url, formversion_id)
    test_rail_result(1, "approvergroupassignments_list body header: #{approvergroupassignments_list.response.headers}")
    test_rail_result(1, "approvergroupassignments_list body: #{approvergroupassignments_list.response.body}")
    resp_code = approvergroupassignments_list.response.code
    expect(resp_code).to eq 200
    test_rail_result(1, "approvergroupassignments_list response code: #{resp_code}", "pass")

    #Step2 Make a Get request on {{protocol}}{{url}}/v3/consent/form_versions/:form_version_id/consent/approver_group_assignments with invalid id
    test_rail_expected_result(2, "The user should receive a 404 Not Found status")
    #Get request on {{protocol}}{{url}}/v3/consent/form_versions/:form_version_id/consent/approver_group_assignments
    invalid_id = test_data["invalid_id"]
    approvergroupassignments_list = V3::Consent::Forms::ApproverGroupAssignments::List.new(super_user_session.token, user_email, base_url, invalid_id)
    test_rail_result(2, "approvergroupassignments_list body header: #{approvergroupassignments_list.response.headers}")
    test_rail_result(2, "approvergroupassignments_list body: #{approvergroupassignments_list.response.body}")
    resp_code = approvergroupassignments_list.response.code
    expect(resp_code).to eq 404
    test_rail_result(2, "approvergroupassignments_list response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a Get request on {{protocol}}{{url}}/v3/consent/form_versions/:form_version_id/consent/approver_group_assignments
    test_rail_expected_result(3, "The user should receive a 403 Forbidden")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/consent/form_versions/:form_version_id/consent/approver_group_assignments
    approvergroupassignments_list = V3::Consent::Forms::ApproverGroupAssignments::List.new(unauthorized_user_session.token, unauthorized_user_email, base_url, formversion_id)
    test_rail_result(3, "approvergroupassignments_list body header: #{approvergroupassignments_list.response.headers}")
    test_rail_result(3, "approvergroupassignments_list body: #{approvergroupassignments_list.response.body}")
    resp_code = approvergroupassignments_list.response.code
    expect(resp_code).to eq 403
    test_rail_result(3, "approvergroupassignments_list response code: #{resp_code}", "pass")
  end

end


