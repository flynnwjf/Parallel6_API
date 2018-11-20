require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_email) { mobile_user["email"] }
  let(:mobile_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:testname) { "cohort_assignment_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:cohort_type){ test_data["cohort_type"] }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C13485 API Client should be able to retrieve all the cohorts a user is assigned to', test_id: 'C13485' do
    test_rail_expected_steps(4)

    #Step1 Make a Post request on {{protocol}}{{url}}/v3/cohort_assignments
    test_rail_expected_result(1, "The result returns a 201 response with details of the cohort association to mobile user.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/cohort_assignments
    cohort_id = V3::Cohort::Create.new(super_user_session.token, user_email, base_url, name, cohort_type).cohort_id
    cohort_assignment_create = V3::Cohort::CohortAssignment::Create.new(super_user_session.token, user_email, base_url, cohort_id, type)
    resp_code = cohort_assignment_create.response.code
    test_rail_result(1, "cohort_assignment_create header: #{cohort_assignment_create.response.headers}")
    test_rail_result(1, "cohort_assignment_create body: #{cohort_assignment_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating cohort assignment response code: #{resp_code}", "pass")

    #Step2 Make a Get request on {{protocol}}{{url}}/v3/mobile_users/{{id}}/cohort_assignments
    test_rail_expected_result(2, "The result returns a 200 response and shows the detail info of cohort assignment")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(2, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(2, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #Get request on {{protocol}}{{url}}/v3/mobile_users/{{id}}/cohort_assignments
    cohort_cohortassignment_index = V3::Cohort::CohortAssignment::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = cohort_cohortassignment_index.response.code
    test_rail_result(2, "cohort_cohortassignment_index header: #{cohort_cohortassignment_index.response.headers}")
    test_rail_result(2, "cohort_cohortassignment_index body: #{cohort_cohortassignment_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "listing all the cohort assignments associated with a mobile user response code: #{resp_code}", "pass")

    #Step3 Make a Get request on {{protocol}}{{url}}/v3/mobile_users/{{id}}/cohort_assignments with invalid id
    test_rail_expected_result(3, "The result returns a 404 response")
    invalid_id = test_data["invalid_id"]
    #Get request on {{protocol}}{{url}}/v3/mobile_users/{{id}}/cohort_assignments
    cohort_cohortassignment_index = V3::Cohort::CohortAssignment::Index.new(super_user_session.token, user_email, base_url, invalid_id)
    resp_code = cohort_cohortassignment_index.response.code
    test_rail_result(3, "cohort_cohortassignment_index header: #{cohort_cohortassignment_index.response.headers}")
    test_rail_result(3, "cohort_cohortassignment_index body: #{cohort_cohortassignment_index.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(3, "listing all the cohort assignments associated with a mobile user response code: #{resp_code}", "pass")

    #Step4 The unauthorized user makes a Get request on {{protocol}}{{url}}/v3/mobile_users/{{id}}/cohort_assignments
    test_rail_expected_result(4, "The result returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/mobile_users/{{id}}/cohort_assignments
    cohort_cohortassignment_index = V3::Cohort::CohortAssignment::Index.new(unauthorized_user_session.token, unauthorized_user_email, base_url, mobile_user_id)
    resp_code = cohort_cohortassignment_index.response.code
    test_rail_result(4, "cohort_cohortassignment_index header: #{cohort_cohortassignment_index.response.headers}")
    test_rail_result(4, "cohort_cohortassignment_index body: #{cohort_cohortassignment_index.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(4, "listing all the cohort assignments associated with a mobile user response code: #{resp_code}", "pass")
  end

end


