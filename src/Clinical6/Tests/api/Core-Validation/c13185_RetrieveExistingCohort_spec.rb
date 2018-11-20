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
  let(:testname) { "cohort_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C13185 API Client should be able to retrieve one existing cohort', test_id: 'C13185' do
    test_rail_expected_steps(3)

    #Step1 Make a Get request on {{protocol}}{{url}}/v3/cohorts/{{id}}
    test_rail_expected_result(1, "It returns a 200 response and only the details of the cohort ID")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/cohorts/{{id}}
    cohort_id = V3::Cohort::Index.new(super_user_session.token, user_email, base_url).id
    show_cohort = V3::Cohort::Show.new(super_user_session.token, user_email, base_url, cohort_id)
    test_rail_result(1, "show_cohort body header: #{show_cohort.response.headers}")
    test_rail_result(1, "show_cohort body: #{show_cohort.response.body}")
    resp_code = show_cohort.response.code
    resp_json = JSON.parse(show_cohort.response.body)
    expect(resp_code).to eq 200
    test_rail_result(1, "show_cohort response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'id')).to eq cohort_id
    test_rail_result(1, "cohort id contained in response: #{cohort_id}", "pass")

    #Step2 Make a Get request on {{protocol}}{{url}}/v3/cohorts/{{id}} with invalid id
    test_rail_expected_result(2, "It returns 404 Record Not Found")
    #Get request on {{protocol}}{{url}}/v3/cohorts/{{id}}
    invalid_id = test_data["invalid_id"]
    show_cohort = V3::Cohort::Show.new(super_user_session.token, user_email, base_url, invalid_id)
    test_rail_result(2, "show_cohort body header: #{show_cohort.response.headers}")
    test_rail_result(2, "show_cohort body: #{show_cohort.response.body}")
    resp_code = show_cohort.response.code
    expect(resp_code).to eq 404
    test_rail_result(2, "show_cohort response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a Get request on {{protocol}}{{url}}/v3/cohorts/{{id}}
    test_rail_expected_result(3, "It returns 403 Forbidden")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/cohorts/{{id}}
    show_cohort = V3::Cohort::Show.new(unauthorized_user_session.token, unauthorized_user_email, base_url, cohort_id)
    test_rail_result(3, "show_cohort body header: #{show_cohort.response.headers}")
    test_rail_result(3, "show_cohort body: #{show_cohort.response.body}")
    resp_code = show_cohort.response.code
    expect(resp_code).to eq 403
    test_rail_result(3, "show_cohort response code: #{resp_code}", "pass")
  end

end


