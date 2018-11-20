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
  let(:testname) { "cohort_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:update_name) { "UpdateTest" + DateTime.new.strftime("%Y%m%d%").to_s }
  let(:cohort_type){ test_data["cohort_type"] }


  it 'C13209 API Client should be able to update the name of a cohort', test_id: 'C13209' do
    test_rail_expected_steps(5)

    #Step1 The user makes a Patch request on {{protocol}}{{url}}/v3/cohorts/:id
    test_rail_expected_result(1, "It returns 200 response and the name is updated to the new one")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Patch request on {{protocol}}{{url}}/v3/cohorts/:id
    cohort_id = V3::Cohort::Index.new(super_user_session.token, user_email, base_url).id
    cohort_update = V3::Cohort::Update.new(super_user_session.token, user_email, base_url, cohort_id, update_name)
    resp_code = cohort_update.response.code
    resp_json = JSON.parse(cohort_update.response.body)
    test_rail_result(1, "cohort_update header: #{cohort_update.response.headers}")
    test_rail_result(1, "cohort_update body: #{cohort_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "updating cohort response code: #{resp_code}", "pass")
    expect(resp_json.dig("data", "attributes", "name")).to eq update_name
    test_rail_result(1, "updating cohort name in response: #{update_name}", "pass")

    #Step2 The user makes a Patch request on {{protocol}}{{url}}/v3/cohorts/:id with invalid name
    test_rail_expected_result(2, "It returns a 422 response")
    #Patch request on {{protocol}}{{url}}/v3/cohorts/:id with invalid name
    invalid_name = ""
    cohort_update = V3::Cohort::Update.new(super_user_session.token, user_email, base_url, cohort_id, invalid_name)
    resp_code = cohort_update.response.code
    test_rail_result(2, "cohort_update header: #{cohort_update.response.headers}")
    test_rail_result(2, "cohort_update body: #{cohort_update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "updating cohort with invalid name response code: #{resp_code}", "pass")

    #Step3 The user makes a Patch request on {{protocol}}{{url}}/v3/cohorts/:id with invalid id
    test_rail_expected_result(3, "It returns a 404 response")
    #Patch request on {{protocol}}{{url}}/v3/cohorts/:id with invalid id
    invalid_id = ""
    cohort_update = V3::Cohort::Update.new(super_user_session.token, user_email, base_url, invalid_id, update_name)
    resp_code = cohort_update.response.code
    test_rail_result(3, "cohort_update header: #{cohort_update.response.headers}")
    test_rail_result(3, "cohort_update body: #{cohort_update.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(3, "updating cohort with invalid id response code: #{resp_code}", "pass")

    #Step4 The user makes a Get request on {{protocol}}{{url}}/v3/cohorts/:id
    test_rail_expected_result(4, "The result returns a 200 response and lists the existing cohorts with the updated name of the cohort.")
    #Get request on {{protocol}}{{url}}/v3/cohorts/:id
    cohort_show = V3::Cohort::Show.new(super_user_session.token, user_email, base_url, cohort_id)
    resp_code = cohort_show.response.code
    resp_json = JSON.parse(cohort_show.response.body)
    test_rail_result(4, "cohort_show header: #{cohort_show.response.headers}")
    test_rail_result(4, "cohort_show body: #{cohort_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(4, "showing cohort with id response code: #{resp_code}", "pass")
    expect(resp_json.dig("data", "attributes", "name")).to eq update_name
    test_rail_result(4, "showing cohort name in response: #{update_name}", "pass")

    #Step5 The unauthorized user makes a Patch request on {{protocol}}{{url}}/v3/cohorts/:id
    test_rail_expected_result(5, "User should receive a 403 status (Forbidden)")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(5, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(5, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Patch request on {{protocol}}{{url}}/v3/cohorts/:id
    cohort_update = V3::Cohort::Update.new(unauthorized_user_session.token, unauthorized_user_email, base_url, cohort_id, update_name)
    resp_code = cohort_update.response.code
    test_rail_result(5, "cohort_update header: #{cohort_update.response.headers}")
    test_rail_result(5, "cohort_update body: #{cohort_update.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(5, "updating cohort response code: #{resp_code}", "pass")
  end

end

