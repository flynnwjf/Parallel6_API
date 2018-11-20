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
  let(:testname) { "cohort_assignment_del" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:type){ test_data["type"] }
  let(:cohort_type){ test_data["cohort_type"] }
  let(:valid_id) { test_data["id"] }
  let(:non_existing_id) { test_data["invalid_id"] }


  it 'C13187 SDK User should be able to remove users from a Cohort' , test_id: 'C13187'do
    test_rail_expected_steps(3)

    #Step1 The user makes a Delete request on {{protocol}}{{url}}/v3/cohort_assignments/{id}
    test_rail_expected_result(1, "The user should receive a 204 No content Status and a blank response")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Delete request on {{protocol}}{{url}}/v3/cohort_assignments/{id}
    cohort_id = V3::Cohort::Create.new(super_user_session.token, user_email, base_url, name, cohort_type).cohort_id
    cohort_assignment_id = V3::Cohort::CohortAssignment::Create.new(super_user_session.token, user_email, base_url, cohort_id, type).cohort_assignment_id
    delete_assignment = V3::Cohort::CohortAssignment::Delete.new(super_user_session.token, user_email, base_url, cohort_assignment_id)
    resp_code = delete_assignment.response.code
    test_rail_result(1, "delete_assignment header: #{delete_assignment.response.headers}")
    test_rail_result(1, "delete_assignment body: #{delete_assignment.response.body}")
    expect(resp_code).to eq 204
    test_rail_result(1, "deleting cohort assignment response code: #{resp_code}", "pass")

    #Step2 The user makes a Delete request on {{protocol}}{{url}}/v3/cohort_assignments/{id} with non-existing assignment
    test_rail_expected_result(2, "User should receive a 404(Not Found)")
    #Delete request on {{protocol}}{{url}}/v3/cohort_assignments/{id} with non-existing assignment
    delete_assignment = V3::Cohort::CohortAssignment::Delete.new(super_user_session.token, user_email, base_url, non_existing_id)
    resp_code = delete_assignment.response.code
    test_rail_result(2, "delete_assignment header: #{delete_assignment.response.headers}")
    test_rail_result(2, "delete_assignment body: #{delete_assignment.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "deleting cohort assignment with non-existing assignment response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a Delete request on {{protocol}}{{url}}/v3/cohort_assignments/{id}
    test_rail_expected_result(3, "User should receive a 403 status (Forbidden)")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Delete request on {{protocol}}{{url}}/v3/cohort_assignments/{id}
    delete_assignment = V3::Cohort::CohortAssignment::Delete.new(unauthorized_user_session.token, unauthorized_user_email, base_url, valid_id)
    resp_code = delete_assignment.response.code
    test_rail_result(3, "delete_assignment header: #{delete_assignment.response.headers}")
    test_rail_result(3, "delete_assignment body: #{delete_assignment.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "deleting cohort assignment response code: #{resp_code}", "pass")
  end

end

