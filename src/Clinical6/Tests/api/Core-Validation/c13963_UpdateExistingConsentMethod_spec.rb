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
  let(:testname) { "consent_strategies_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "UpdateTest-" + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C13963 API Client should be able to update an existing Consent Method', test_id: 'C13963' do
    test_rail_expected_steps(6)

    #Step1 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    test_rail_expected_result(1, "It returns a 200 response and the updated name")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    strategy_id = V3::Consent::Strategies::Index.new(super_user_session.token, user_email, base_url).id
    strategy_update = V3::Consent::Strategies::Update.new(super_user_session.token, user_email, base_url, strategy_id, name)
    resp_code = strategy_update.response.code
    resp_json = JSON.parse(strategy_update.response.body)
    test_rail_result(1, "strategy_update header: #{strategy_update.response.headers}")
    test_rail_result(1, "strategy_update body: #{strategy_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "updating consent strategy response code: #{resp_code}", "pass")
    expect(resp_json.dig("data", "attributes", "name")).to eq name
    test_rail_result(1, "updating consent strategy name in response: #{name}", "pass")

    #Step2 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}} with invalid id
    test_rail_expected_result(2, "It returns a 404 response with the error message")
    #Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    invalid_id = test_data["invalid_id"]
    strategy_update = V3::Consent::Strategies::Update.new(super_user_session.token, user_email, base_url, invalid_id, name)
    resp_code = strategy_update.response.code
    test_rail_result(2, "strategy_update header: #{strategy_update.response.headers}")
    test_rail_result(2, "strategy_update body: #{strategy_update.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "updating consent strategy response code: #{resp_code}", "pass")

    #Step3 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    test_rail_expected_result(3, "It returns a 200 response and the strategy_type is not updated")
    #Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    strategy_type = V3::Consent::Strategies::Index.new(super_user_session.token, user_email, base_url).type
    strategy_update = V3::Consent::Strategies::Update.new(super_user_session.token, user_email, base_url, strategy_id, name)
    resp_code = strategy_update.response_type.code
    resp_json = JSON.parse(strategy_update.response_type.body)
    test_rail_result(3, "strategy_update header: #{strategy_update.response_type.headers}")
    test_rail_result(3, "strategy_update body: #{strategy_update.response_type.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "updating consent strategy response code: #{resp_code}", "pass")
    expect(resp_json.dig("data", "attributes", "type")).to eq strategy_type
    test_rail_result(3, "consent strategy type is not updated in response: #{strategy_type}", "pass")

    #Step4 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}} with invalid name
    test_rail_expected_result(4, "It returns 422 response with the error message")
    #Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    invalid_name = ""
    strategy_update = V3::Consent::Strategies::Update.new(super_user_session.token, user_email, base_url, strategy_id, invalid_name)
    resp_code = strategy_update.response.code
    test_rail_result(4, "strategy_update header: #{strategy_update.response.headers}")
    test_rail_result(4, "strategy_update body: #{strategy_update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(4, "updating consent strategy response code: #{resp_code}", "pass")

    #Step5 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}} with same name
    test_rail_expected_result(5, "It returns 422 response with the error message")
    #Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    #The name of first form in form list
    existing_name = JSON.parse(V3::Consent::Strategies::Index.new(super_user_session.token, user_email, base_url).response.body).dig("data", 0, "attributes", "name")
    test_rail_result(5, "existing name is: #{existing_name}")
    strategy_update = V3::Consent::Strategies::Update.new(super_user_session.token, user_email, base_url, strategy_id, existing_name)
    resp_code = strategy_update.response.code
    test_rail_result(5, "strategy_update header: #{strategy_update.response.headers}")
    test_rail_result(5, "strategy_update body: #{strategy_update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(5, "updating consent strategy response code: #{resp_code}", "pass")

    #Step6 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    test_rail_expected_result(6, "It returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(6, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(6, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Patch request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    strategy_update = V3::Consent::Strategies::Update.new(unauthorized_user_session.token, unauthorized_user_email, base_url, strategy_id, name)
    resp_code = strategy_update.response.code
    test_rail_result(6, "strategy_update header: #{strategy_update.response.headers}")
    test_rail_result(6, "strategy_update body: #{strategy_update.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(6, "updating consent strategy response code: #{resp_code}", "pass")
  end

end

