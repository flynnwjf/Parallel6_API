require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "c12551_UserAbleToDestroySession" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:cohort_name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:cohort_type) { "static" }

  it 'C12551 - Admin User should be able destroy his session so that no one can continue using his authentication token', test_id: 'C12551' do
    test_rail_expected_steps(5)

    #Step1 sends a POST request on {{protocol}}{{url}}/v3/users/session
    test_rail_expected_result(1, "A new session got created with a 201 status")
    new_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    new_session_token = new_session.token
    test_rail_result(1, "response header: #{new_session.response.headers}")
    test_rail_result(1, "response body: #{new_session.response.body}")
    expect(new_session.response.code).to eq 201
    test_rail_result(1, "new session response code: #{new_session.response.code}", "pass")

    #Step2  <Adminuser> with permissions makes a POST request on {{protocol}}{{url}}/v3/cohorts
    test_rail_expected_result(2, "The user should should see a 201 created status")
    cohort_create = V3::Cohort::Create.new(new_session_token, user_email, base_url, cohort_name, cohort_type)
    test_rail_result(2, "cohort_create header: #{cohort_create.response.headers}")
    test_rail_result(2, "cohort_create body: #{cohort_create.response.body}")
    expect(cohort_create.response.code).to eq 201
    test_rail_result(2, "cohort_create code: #{cohort_create.response.code}", "pass")

    #Step3 <Adminuser> makes a DELETE request on {{protocol}}{{url}}/v3/users/session
    test_rail_expected_result(3, "The user should see 204 No Content status and the response should be blank")
    delete_session = V3::Users::Session::Delete.new(new_session_token, user_email, base_url)
    test_rail_result(3, "delete_session header: #{delete_session.response.headers}")
    test_rail_result(3, "delete_session body: #{delete_session.response.body}")
    expect(delete_session.response.code).to eq 204
    test_rail_result(3, "cohort_create code: #{delete_session.response.code}", "pass")

    #Step4 Using the token from step 1 make a POST request on {{protocol}}{{url}}/v3/cohorts
    test_rail_expected_result(4, "The user should received a 401 Unauthorized, as the session was deleted")
    cohort_create = V3::Cohort::Create.new(new_session_token, user_email, base_url, cohort_name, cohort_type)
    test_rail_result(4, "cohort_create header: #{cohort_create.response.headers}")
    test_rail_result(4, "cohort_create body: #{cohort_create.response.body}")
    expect(cohort_create.response.code).to eq 401
    test_rail_result(4, "cohort_create code: #{cohort_create.response.code}", "pass")

    #Step5 Using the token from step 1 make a DELETE request on {{protocol}}{{url}}/v3/users/session
    test_rail_expected_result(5, "The user should received a 401 Unauthorized, as the session does not exist")
    delete_session = V3::Users::Session::Delete.new(new_session_token, user_email, base_url)
    test_rail_result(5, "delete_session header: #{delete_session.response.headers}")
    test_rail_result(5, "delete_session body: #{delete_session.response.body}")
    expect(delete_session.response.code).to eq 401
    test_rail_result(5, "cohort_create code: #{delete_session.response.code}", "pass")
  end
end
