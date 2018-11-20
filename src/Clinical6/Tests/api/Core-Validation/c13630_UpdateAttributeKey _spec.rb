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
  let(:testname) { "dynamiccontent_attributekeys_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:name) { test_data["name"] + DateTime.now.strftime('_%Q').to_s }
  let(:display_name) { test_data["display_name"] }


  it 'C13630 SDK User should be able to update an Attribute Key', test_id: 'C13630' do
    test_rail_expected_steps(5)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    test_rail_expected_result(1, "User should receive a response with a new attribute key and a 201 Created status")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    attribute_keys = V3::DynamicContent::AttributeKeys::Create.new(super_user_session.token, user_email, base_url, type, name, name)
    key_id = attribute_keys.id
    resp_code = attribute_keys.response.code
    expect(resp_code).to eq 201
    test_rail_result(1, "creating attribute keys response code: #{resp_code}", "pass")

    #Step2 The user makes a PATCH request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    test_rail_expected_result(2, "User should receive an updated attribute key response with a new name and a 200 OK status")
    #PATCH request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    attribute_keys_update = V3::DynamicContent::AttributeKeys::Update.new(super_user_session.token, user_email, base_url, key_id, type, name, display_name)
    resp_code = attribute_keys_update.response.code
    resp_json = JSON.parse(attribute_keys_update.response.body)
    test_rail_result(2, "attribute_keys_update header: #{attribute_keys_update.response.headers}")
    test_rail_result(2, "attribute_keys_update body: #{attribute_keys_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "updating attribute keys response code: #{resp_code}", "pass")
    expect(resp_json.dig('data','attributes','display_name')).to eq display_name
    test_rail_result(2, "updating attribute keys name in response: #{display_name}", "pass")

    #Step3 The user makes a PATCH request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    test_rail_expected_result(3, "User should receive a 404 Not found")
    #PATCH request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    invalid_id = test_data["invalid_id"]
    attribute_keys_update = V3::DynamicContent::AttributeKeys::Update.new(super_user_session.token, user_email, base_url, invalid_id, type, name, display_name)
    resp_code = attribute_keys_update.response.code
    test_rail_result(3, "attribute_keys_update header: #{attribute_keys_update.response.headers}")
    test_rail_result(3, "attribute_keys_update body: #{attribute_keys_update.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(3, "updating attribute keys response code: #{resp_code}", "pass")

    #Step4 The user makes a PATCH request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    test_rail_expected_result(4, "User should receive a 422 Unprocessable Entry")
    #PATCH request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    invalid_name = test_data["invalid_key_name"]
    attribute_keys_update = V3::DynamicContent::AttributeKeys::Update.new(super_user_session.token, user_email, base_url, key_id, type, invalid_name, display_name)
    resp_code = attribute_keys_update.response.code
    test_rail_result(4, "attribute_keys_update header: #{attribute_keys_update.response.headers}")
    test_rail_result(4, "attribute_keys_update body: #{attribute_keys_update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(4, "updating attribute keys response code: #{resp_code}", "pass")

    #Step5 The unauthorized user makes a PATCH request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    test_rail_expected_result(5, "User should receive a 403 Forbidden")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(5, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(5, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #PATCH request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    attribute_keys_update = V3::DynamicContent::AttributeKeys::Update.new(unauthorized_user_session.token, unauthorized_user_email, base_url, key_id, type, name, display_name)
    resp_code = attribute_keys_update.response.code
    test_rail_result(5, "attribute_keys_update header: #{attribute_keys_update.response.headers}")
    test_rail_result(5, "attribute_keys_update body: #{attribute_keys_update.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(5, "updating attribute keys response code: #{resp_code}", "pass")
  end

end

