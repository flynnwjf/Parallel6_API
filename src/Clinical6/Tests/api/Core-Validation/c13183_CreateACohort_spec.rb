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
  let(:testname) { "cohort_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:invalid_name) { test_data["invalid_name"] }
  let(:type){ test_data["type"] }


  it 'C13183 Admin User should be able to create a Cohort(recipient group)', test_id: 'C13183' do
    test_rail_expected_steps(3)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/cohorts
    test_rail_expected_result(1, "A new cohort should get created, with a 201 status. The user should see the created cohort displayed with a unique id")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/cohorts
    cohort = V3::Cohort::Create.new(super_user_session.token, user_email, base_url, name, type)
    resp_code = cohort.response.code
    resp_json = JSON.parse(cohort.response.body)
    test_rail_result(1, "cohort header: #{cohort.response.headers}")
    test_rail_result(1, "cohort body: #{cohort.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating cohort response code: #{resp_code}", "pass")
    cohort_id = resp_json.dig('data', 'id')
    expect(cohort_id).not_to eq nil
    test_rail_result(1, "created cohort id in response: #{cohort_id}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/cohorts with invalid parameters
    test_rail_expected_result(2, "User receives a 422 Unprocessible entity response and New cohort is not created")
    #POST request on {{protocol}}{{url}}/v3/cohorts with invalid parameters
    cohort = V3::Cohort::Create.new(super_user_session.token, user_email, base_url, invalid_name, type)
    resp_code = cohort.response.code
    test_rail_result(2, "cohort header: #{cohort.response.headers}")
    test_rail_result(2, "cohort body: #{cohort.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating cohort with invalid parameters response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a post request on {{protocol}}{{url}}/v3/cohorts
    test_rail_expected_result(3, "User should receive a 403 status (Forbidden)")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/cohorts
    cohort = V3::Cohort::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, name, type)
    resp_code = cohort.response.code
    test_rail_result(3, "cohort header: #{cohort.response.headers}")
    test_rail_result(3, "cohort body: #{cohort.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "creating cohort response code: #{resp_code}", "pass")
  end

end

