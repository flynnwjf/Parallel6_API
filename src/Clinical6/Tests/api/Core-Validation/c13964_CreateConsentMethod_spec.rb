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
  let(:testname) { "consent_strategies_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:type) { test_data["type"] }


  it 'C13964 API Client should be able to create the methods that can be used by patients to consent', test_id: 'C13964' do
    test_rail_expected_steps(6)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/consent/strategies
    test_rail_expected_result(1, "It returns a 201 response and details for the new consent method")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/consent/strategies
    cohort_id = V3::Cohort::Index.new(super_user_session.token, user_email, base_url).id
    consent_strategies_create = V3::Consent::Strategies::Create.new(super_user_session.token, user_email, base_url, name, type, cohort_id)
    resp_code = consent_strategies_create.response.code
    test_rail_result(1, "consent_strategies_create header: #{consent_strategies_create.response.headers}")
    test_rail_result(1, "consent_strategies_create body: #{consent_strategies_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating consent method response code: #{resp_code}", "pass")

    #Step2 The user makes a Post request on {{protocol}}{{url}}/v3/consent/strategies with blank strategy
    test_rail_expected_result(2, "It returns a 422 response with the error message detail can't be blank.")
    #Post request on {{protocol}}{{url}}/v3/consent/strategies
    blank_type = ""
    consent_strategies_create = V3::Consent::Strategies::Create.new(super_user_session.token, user_email, base_url, name, blank_type, cohort_id)
    resp_code = consent_strategies_create.response.code
    test_rail_result(2, "consent_strategies_create header: #{consent_strategies_create.response.headers}")
    test_rail_result(2, "consent_strategies_create body: #{consent_strategies_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating consent method response code: #{resp_code}", "pass")

    #Step3 The user makes a Post request on {{protocol}}{{url}}/v3/consent/strategies with invalid strategy
    test_rail_expected_result(3, "It returns a 422 response with the error message detail '{{invalid value}}' is not a valid strategy_type.")
    #Post request on {{protocol}}{{url}}/v3/consent/strategies
    invalid_type = "testingtype"
    consent_strategies_create = V3::Consent::Strategies::Create.new(super_user_session.token, user_email, base_url, name, invalid_type, cohort_id)
    resp_code = consent_strategies_create.response.code
    test_rail_result(3, "consent_strategies_create header: #{consent_strategies_create.response.headers}")
    test_rail_result(3, "consent_strategies_create body: #{consent_strategies_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(3, "creating consent method response code: #{resp_code}", "pass")

    #Step4 The user makes a Post request on {{protocol}}{{url}}/v3/consent/strategies with existing name
    test_rail_expected_result(4, "It returns a 422 response with the error message detail 'has already been taken.")
    #Post request on {{protocol}}{{url}}/v3/consent/strategies
    consent_strategies_create = V3::Consent::Strategies::Create.new(super_user_session.token, user_email, base_url, name, type, cohort_id)
    resp_code = consent_strategies_create.response.code
    test_rail_result(4, "consent_strategies_create header: #{consent_strategies_create.response.headers}")
    test_rail_result(4, "consent_strategies_create body: #{consent_strategies_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(4, "creating consent method response code: #{resp_code}", "pass")

    #Step5 The user makes a Post request on {{protocol}}{{url}}/v3/consent/strategies with blank name
    test_rail_expected_result(5, "It returns a 422 response with the error message detail can't be blank.")
    #Post request on {{protocol}}{{url}}/v3/consent/strategies
    blank_name = ""
    consent_strategies_create = V3::Consent::Strategies::Create.new(super_user_session.token, user_email, base_url, blank_name, type, cohort_id)
    resp_code = consent_strategies_create.response.code
    test_rail_result(5, "consent_strategies_create header: #{consent_strategies_create.response.headers}")
    test_rail_result(5, "consent_strategies_create body: #{consent_strategies_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(5, "creating consent method response code: #{resp_code}", "pass")

    #Step6 The unauthorized user makes a POST request on {{protocol}}{{url}}/v3/consent/strategies
    test_rail_expected_result(6, "It returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(6, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(6, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/consent/strategies
    consent_strategies_create = V3::Consent::Strategies::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, name, type, cohort_id)
    resp_code = consent_strategies_create.response.code
    test_rail_result(6, "consent_strategies_create header: #{consent_strategies_create.response.headers}")
    test_rail_result(6, "consent_strategies_create body: #{consent_strategies_create.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(6, "creating consent method response code: #{resp_code}", "pass")
  end

end

