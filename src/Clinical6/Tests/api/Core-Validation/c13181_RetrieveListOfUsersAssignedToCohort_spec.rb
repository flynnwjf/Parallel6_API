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
  let(:testname) { "agreement_templates_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }

  it 'C13181 User should be able to retrieve the list of users assigned to the Cohort', test_id: 'C13181' do
    test_rail_expected_steps(3)

    #Step1 Make a GET request on {{protocol}}{{url}}/v3/cohorts/{id}/cohort_assignments
    test_rail_expected_result(1, "User should get a response with a list of users assigned to the cohort and a 200 OK Status")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #GET request on {{protocol}}{{url}}/v3/cohorts/{id}/cohort_assignments
    cohort_id = V3::Cohort::Create.new(super_user_session.token, user_email, base_url, name, "static").cohort_id
    cohort_cohortassignment_index = V3::Cohort::CohortAssignment::Index.new(super_user_session.token, user_email, base_url, cohort_id)
    resp_code = cohort_cohortassignment_index.response.code
    test_rail_result(1, "cohort_cohortassignment_index header: #{cohort_cohortassignment_index.response.headers}")
    test_rail_result(1, "cohort_cohortassignment_index body: #{cohort_cohortassignment_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting a list of users assigned to the cohort response code: #{resp_code}", "pass")

    #Step2 Make a Get request on {{protocol}}{{url}}/v3/cohorts/{id}/cohort_assignments with invalid parameter
    test_rail_expected_result(2, "User should receive a 404 response")
    #Get request on {{protocol}}{{url}}/v3/cohorts/{id}/cohort_assignments
    invalid_id = test_data["invalid_id"]
    cohort_cohortassignment_index = V3::Cohort::CohortAssignment::Index.new(super_user_session.token, user_email, base_url, invalid_id)
    resp_code = cohort_cohortassignment_index.response.code
    test_rail_result(2, "cohort_cohortassignment_index header: #{cohort_cohortassignment_index.response.headers}")
    test_rail_result(2, "cohort_cohortassignment_index body: #{cohort_cohortassignment_index.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "getting a list of users assigned to the cohort response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a Get request on {{protocol}}{{url}}/v3/cohorts/{id}/cohort_assignments}
    test_rail_expected_result(3, "The result returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/cohorts/{id}/cohort_assignments
    cohort_cohortassignment_index = V3::Cohort::CohortAssignment::Index.new(unauthorized_user_session.token, unauthorized_user_email, base_url, cohort_id)
    resp_code = cohort_cohortassignment_index.response.code
    test_rail_result(3, "cohort_cohortassignment_index header: #{cohort_cohortassignment_index.response.headers}")
    test_rail_result(3, "cohort_cohortassignment_index body: #{cohort_cohortassignment_index.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "getting a list of users assigned to the cohort response code: #{resp_code}", "pass")
  end

end


