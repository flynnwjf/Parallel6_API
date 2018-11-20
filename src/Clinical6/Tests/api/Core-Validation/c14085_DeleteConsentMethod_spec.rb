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


  it 'C14085 API Client should be able to delete a consent method', test_id: 'C14085' do
    test_rail_expected_steps(4)

    #Step1 The user makes a DELETE request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    test_rail_expected_result(1, "It returns a 204 response.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #DELETE request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    strategy_id = V3::Consent::Strategies::Index.new(super_user_session.token, user_email, base_url).id
    consent_strategies_delete = V3::Consent::Strategies::Delete.new(super_user_session.token, user_email, base_url, strategy_id)
    resp_code = consent_strategies_delete.response.code
    test_rail_result(1, "consent_strategies_delete header: #{consent_strategies_delete.response.headers}")
    test_rail_result(1, "consent_strategies_delete body: #{consent_strategies_delete.response.body}")
    expect(resp_code).to eq 204
    test_rail_result(1, "deleting consent method response code: #{resp_code}", "pass")

    #Step2 The user makes a DELETE request on {{protocol}}{{url}}/v3/consent/strategies/{{id}} with invalid id
    test_rail_expected_result(2, "It returns a 404 response.")
    #DELETE request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    invalid_id = test_data["invalid_id"]
    consent_strategies_delete = V3::Consent::Strategies::Delete.new(super_user_session.token, user_email, base_url, invalid_id)
    resp_code = consent_strategies_delete.response.code
    test_rail_result(2, "consent_strategies_delete header: #{consent_strategies_delete.response.headers}")
    test_rail_result(2, "consent_strategies_delete body: #{consent_strategies_delete.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "deleting consent method response code: #{resp_code}", "pass")

    #Step3 The user makes a GET request: {{protocol}}{{url}}/v3/consent/strategies
    test_rail_expected_result(3, "It returns a 200 response and the previously deleted consent method is not listed.")
    #GET request: {{protocol}}{{url}}/v3/consent/strategies
    consent_strategies_index = V3::Consent::Strategies::Index.new(super_user_session.token, user_email, base_url)
    resp_code = consent_strategies_index.response.code
    resp_json = JSON.parse(consent_strategies_index.response.body)
    test_rail_result(3, "consent_strategies_index header: #{consent_strategies_index.response.headers}")
    test_rail_result(3, "consent_strategies_index body: #{consent_strategies_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting consent method response code: #{resp_code}", "pass")
    deleted_id = resp_json['data'].any? { |data| data.dig('id') != "#{strategy_id}"}
    expect(deleted_id).to be true
    test_rail_result(3, "deleted consent method not in response: #{deleted_id}", "pass")

    #Step4 The unauthorized user makes a DELETE request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    test_rail_expected_result(4, "It returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #DELETE request on {{protocol}}{{url}}/v3/consent/strategies/{{id}}
    consent_strategies_delete = V3::Consent::Strategies::Delete.new(unauthorized_user_session.token, unauthorized_user_email, base_url, 1)
    resp_code = consent_strategies_delete.response.code
    test_rail_result(4, "consent_strategies_delete header: #{consent_strategies_delete.response.headers}")
    test_rail_result(4, "consent_strategies_delete body: #{consent_strategies_delete.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(4, "deleting consent method response code: #{resp_code}", "pass")
  end

end

