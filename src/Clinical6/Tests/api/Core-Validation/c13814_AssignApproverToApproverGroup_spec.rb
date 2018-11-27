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
  let(:testname) { "consent_approver_assignments_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C13814 API Client should be able to assign an approver to an existing ApproverGroup', test_id: 'C13814' do
    test_rail_expected_steps(4)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/consent/approver_assignments
    test_rail_expected_result(1, "It returns a 201 response and returns details of the approver assignment to approver group.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/consent/approver_assignments
    approver_id = V3::Consent::Approvers::Index.new(super_user_session.token, user_email, base_url).id
    group_id = V3::Consent::ApproverGroups::Index.new(super_user_session.token, user_email, base_url).id
    consent_approver_assignments_create = V3::Consent::ApproverAssignments::Create.new(super_user_session.token, user_email, base_url, approver_id, group_id)
    resp_code = consent_approver_assignments_create.response.code
    test_rail_result(1, "consent_approver_assignments_create header: #{consent_approver_assignments_create.response.headers}")
    test_rail_result(1, "consent_approver_assignments_create body: #{consent_approver_assignments_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating consent approver assignments response code: #{resp_code}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/consent/approver_assignments without approver
    test_rail_expected_result(2, "It returns a 422 response with the error message detail can't be blank.")
    #POST request on {{protocol}}{{url}}/v3/consent/approver_assignments
    blank_approver = ""
    consent_approver_assignments_create = V3::Consent::ApproverAssignments::Create.new(super_user_session.token, user_email, base_url, blank_approver, group_id)
    resp_code = consent_approver_assignments_create.response.code
    test_rail_result(2, "consent_approver_assignments_create header: #{consent_approver_assignments_create.response.headers}")
    test_rail_result(2, "consent_approver_assignments_create body: #{consent_approver_assignments_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating consent approver assignments response code: #{resp_code}", "pass")

    #Step3 The user makes a POST request on {{protocol}}{{url}}/v3/consent/approver_assignments without approver group
    test_rail_expected_result(3, "It returns a 422 response with the error message detail can't be blank.")
    #POST request on {{protocol}}{{url}}/v3/consent/approver_assignments
    blank_group = ""
    consent_approver_assignments_create = V3::Consent::ApproverAssignments::Create.new(super_user_session.token, user_email, base_url, approver_id, blank_group)
    resp_code = consent_approver_assignments_create.response.code
    test_rail_result(3, "consent_approver_assignments_create header: #{consent_approver_assignments_create.response.headers}")
    test_rail_result(3, "consent_approver_assignments_create body: #{consent_approver_assignments_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(3, "creating consent approver assignments response code: #{resp_code}", "pass")

    #Step4 The unauthorized user makes a POST request on {{protocol}}{{url}}/v3/consent/approver_assignments
    test_rail_expected_result(4, "It returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/consent/approver_assignments
    consent_approver_assignments_create = V3::Consent::ApproverAssignments::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, approver_id, group_id)
    resp_code = consent_approver_assignments_create.response.code
    test_rail_result(4, "consent_approver_assignments_create header: #{consent_approver_assignments_create.response.headers}")
    test_rail_result(4, "consent_approver_assignments_create body: #{consent_approver_assignments_create.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(4, "creating consent approver assignments response code: #{resp_code}", "pass")
  end

end

