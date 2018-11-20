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
  let(:testname) { "cohort_assignment_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:cohort_type){ test_data["cohort_type"] }


  it 'C13182 Admin User should be able to add a new user to the Cohort', test_id: 'C13182' do
    test_rail_expected_steps(5)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/cohorts
    test_rail_expected_result(1, "A new cohort should get created, with a 201 status")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/cohorts
    cohort_create = V3::Cohort::Create.new(super_user_session.token, user_email, base_url, name,cohort_type)
    resp_code = cohort_create.response.code
    resp_json = JSON.parse(cohort_create.response.body)
    test_rail_result(1, "cohort_create header: #{cohort_create.response.headers}")
    test_rail_result(1, "cohort_create body: #{cohort_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating cohort response code: #{resp_code}", "pass")
    cohort_id = resp_json.dig("data", "id")
    expect(cohort_id).not_to eq nil
    test_rail_result(1, "craeted cohort id in response: #{cohort_id}", "pass")

    #Step2 The user makes a Post request on {{protocol}}{{url}}/v3/cohort_assignments
    test_rail_expected_result(2, "A user got added to the cohort with a 201 status")
    #Post request on {{protocol}}{{url}}/v3/cohort_assignments
    cohort_assignment_create = V3::Cohort::CohortAssignment::Create.new(super_user_session.token, user_email, base_url, cohort_id, type)
    resp_code = cohort_assignment_create.response.code
    resp_json = JSON.parse(cohort_assignment_create.response.body)
    test_rail_result(2, "cohort_assignment_create header: #{cohort_assignment_create.response.headers}")
    test_rail_result(2, "cohort_assignment_create body: #{cohort_assignment_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(2, "creating cohort assignment response code: #{resp_code}", "pass")
    assignment_id = resp_json.dig("data", "id")
    expect(assignment_id).not_to eq nil
    test_rail_result(2, "craeted cohort assignment id in response: #{assignment_id}", "pass")

    #Step3 The user makes a Post request on {{protocol}}{{url}}/v3/cohort_assignments with invalid parameter
    test_rail_expected_result(3, "The user should receive a 422(Unprocessable entry)")
    #Post request on {{protocol}}{{url}}/v3/cohort_assignments
    invalid_id = test_data["invalid_id"]
    cohort_assignment_create = V3::Cohort::CohortAssignment::Create.new(super_user_session.token, user_email, base_url, invalid_id, type)
    resp_code = cohort_assignment_create.response.code
    test_rail_result(3, "cohort_assignment_create header: #{cohort_assignment_create.response.headers}")
    test_rail_result(3, "cohort_assignment_create body: #{cohort_assignment_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(3, "creating cohort assignment response code: #{resp_code}", "pass")

    #Step4 The user makes a Post request on {{protocol}}{{url}}/v3/cohort_assignments with existing cohort
    test_rail_expected_result(4, "The user should receive a 422(Unprocessable entry)")
    #Post request on {{protocol}}{{url}}/v3/cohort_assignments
    cohort_assignment_create = V3::Cohort::CohortAssignment::Create.new(super_user_session.token, user_email, base_url, cohort_id, type)
    resp_code = cohort_assignment_create.response.code
    test_rail_result(4, "cohort_assignment_create header: #{cohort_assignment_create.response.headers}")
    test_rail_result(4, "cohort_assignment_create body: #{cohort_assignment_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(4, "creating cohort assignment response code: #{resp_code}", "pass")

    #Step5 The unauthorized user makes a Post request on {{protocol}}{{url}}/v3/cohort_assignments
    test_rail_expected_result(5, "The user should receive a 403 status (Forbidden)")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(5, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(5, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/cohort_assignments
    cohort_assignment_create = V3::Cohort::CohortAssignment::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, cohort_id, type)
    resp_code = cohort_assignment_create.response.code
    test_rail_result(5, "cohort_assignment_create header: #{cohort_assignment_create.response.headers}")
    test_rail_result(5, "cohort_assignment_create body: #{cohort_assignment_create.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(5, "creating cohort assignment response code: #{resp_code}", "pass")
  end

end

