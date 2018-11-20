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
  let(:testname) { "consent_approver_group_assignments_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:form_version_id) { test_data["form_version_id"] }
  let(:group_id) { rand(50..100)}
#Requests
#let(:consent_approver_group_assignments_del) { V3::Consent::ApproverGroupAssignments::Delete.new(token, user_email, base_url, id) }
#let(:id) { consent_approver_group_assignments_create.id }


  it 'C13813 API Client should be able to remove the association between an approver group and a form version without deleting the approver group', test_id: 'C13813' do
    test_rail_expected_steps(4)

    #Step1 Makes a POST request on {{protocol}}{{url}}/v3/consent/approver_group_assignments
    test_rail_expected_result(1, "201 response with the created consent__approver_group_assignments id")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")

    cnsnt_apprvr_grp_asgnmt_create = V3::Consent::ApproverGroupAssignments::Create.new(super_user_session.token, user_email, base_url, 2, 3)
    test_rail_result(1, "consent_approver_group_assignments_create header: #{cnsnt_apprvr_grp_asgnmt_create.response.headers}")
    test_rail_result(1, "consent_approver_group_assignments_create body: #{cnsnt_apprvr_grp_asgnmt_create.response.body}")
    expect(cnsnt_apprvr_grp_asgnmt_create.response.code).to eq 201
    expect(JSON.parse(cnsnt_apprvr_grp_asgnmt_create.response.body).dig("data", "type")).to eq "consent__approver_group_assignments"
    test_rail_result(1, "consent_approver_group_assignments_create response code: #{cnsnt_apprvr_grp_asgnmt_create.response.code}", "pass")

    #Step2 Try to make a DELETE request on {{protocol}}{{url}}/v3/consent/approver_group_assignments/:id
    #with the valid id which is created in step 1 and unauthorized user
    test_rail_expected_result(2, "User can get 403 response with Record Not Found message")
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(2, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(2, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    consent_approver_group_assignments_del = V3::Consent::ApproverGroupAssignments::Delete.new(unauthorized_user_session.token, unauthorized_user_email, base_url, cnsnt_apprvr_grp_asgnmt_create.id)
    test_rail_result(2, "consent_approver_group_assignments_del header: #{consent_approver_group_assignments_del.response.headers}")
    test_rail_result(2, "consent_approver_group_assignments_del body: #{consent_approver_group_assignments_del.response.body}")
    expect(consent_approver_group_assignments_del.response.code).to eq 403
    test_rail_result(2, "consent_approver_group_assignments_create response code: #{consent_approver_group_assignments_del.response.code}", "pass")


    #Step3 Make a DELETE request on {{protocol}}{{url}}/v3/consent/approver_group_assignments/:id
    #with the valid id which is created in step 1
    test_rail_expected_result(3, "User can get 204 response without content")
    consent_approver_group_assignments_del = V3::Consent::ApproverGroupAssignments::Delete.new(super_user_session.token, user_email, base_url, cnsnt_apprvr_grp_asgnmt_create.id)
    test_rail_result(3, "consent_approver_group_assignments_del header: #{consent_approver_group_assignments_del.response.headers}")
    test_rail_result(3, "consent_approver_group_assignments_del body: #{consent_approver_group_assignments_del.response.body}")
    expect(consent_approver_group_assignments_del.response.code).to eq 204
    test_rail_result(3, "consent_approver_group_assignments_create response code: #{consent_approver_group_assignments_del.response.code}", "pass")

    #Step4 Try to make a DELETE request on {{protocol}}{{url}}/v3/consent/approver_group_assignments/:id
    # with the valid id which is created in step 1 again
    test_rail_expected_result(4, "User can get 404 response with Record Not Found message")
    consent_approver_group_assignments_del = V3::Consent::ApproverGroupAssignments::Delete.new(super_user_session.token, user_email, base_url, cnsnt_apprvr_grp_asgnmt_create.id)
    test_rail_result(4, "consent_approver_group_assignments_del header: #{consent_approver_group_assignments_del.response.headers}")
    test_rail_result(4, "consent_approver_group_assignments_del body: #{consent_approver_group_assignments_del.response.body}")
    expect(consent_approver_group_assignments_del.response.code).to eq 404
    test_rail_result(4, "consent_approver_group_assignments_create response code: #{consent_approver_group_assignments_del.response.code}", "pass")



  end

end

