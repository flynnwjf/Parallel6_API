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
  let(:testname) { "cohort_cohortassignment_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C14285 User\'s profile should be included when listing the members of a cohort', test_id: 'C14285' do
    test_rail_expected_steps(3)

    #Step1 Make a Get request on {{protocol}}{{url}}/v3/cohorts
    test_rail_expected_result(1, "User can get 200 response with a list of the cohorts and available cohort id")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/cohorts
    cohort = V3::Cohort::Index.new(super_user_session.token, user_email, base_url)
    test_rail_result(1, "cohort body header: #{cohort.response.headers}")
    test_rail_result(1, "cohort body: #{cohort.response.body}")
    resp_code = cohort.response.code
    expect(resp_code).to eq 200
    test_rail_result(1, "cohort response code: #{resp_code}", "pass")
    cohort_id = test_data["id"]
    JSON.parse(cohort.response.body)['data'].each do |type|
      if (type.dig('attributes', 'cohort_type') == "static")
        cohort_id = type.dig('id')
        break
      end
    end

    #Step2 Make a Get request on {{protocol}}{{url}}/v3/cohorts/:id/cohort_assignments
    test_rail_expected_result(2, "User can get 200 response with a list of the cohort associations for a given cohort")
    #Get request on {{protocol}}{{url}}/v3/cohorts/:id/cohort_assignments
    cohort_assignments = V3::Cohort::CohortAssignment::Index.new(super_user_session.token, user_email, base_url, cohort_id)
    test_rail_result(2, "cohort_assignments body header: #{cohort_assignments.response.headers}")
    test_rail_result(2, "cohort_assignments body: #{cohort_assignments.response.body}")
    resp_code = cohort_assignments.response.code
    expect(resp_code).to eq 200
    test_rail_result(2, "cohort_assignments response code: #{resp_code}", "pass")

    #Step3 Make a Get request on {{protocol}}{{url}}/v3/cohorts/:id/cohort_assignments with invalid id
    test_rail_expected_result(3, "User can get 404 Record Not Found")
    #Get request on {{protocol}}{{url}}/v3/cohorts/:id/cohort_assignments
    invalid_id = test_data["invalid_id"]
    cohort_assignments = V3::Cohort::CohortAssignment::Index.new(super_user_session.token, user_email, base_url, invalid_id)
    test_rail_result(3, "cohort_assignments body header: #{cohort_assignments.response.headers}")
    test_rail_result(3, "cohort_assignments body: #{cohort_assignments.response.body}")
    resp_code = cohort_assignments.response.code
    expect(resp_code).to eq 404
    test_rail_result(3, "cohort_assignments response code: #{resp_code}", "pass")
  end

end


