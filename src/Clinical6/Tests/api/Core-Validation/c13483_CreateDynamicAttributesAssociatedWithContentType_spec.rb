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
  let(:testname) { "dynamiccontent_attributekeys_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:type_id) { test_data["type_id"] }
  let(:name) { test_data["name"] + DateTime.now.strftime('_%Q').to_s }
  let(:display_name) { test_data["display_name"] }

  it 'C13483 SDK User should be able to retrieve all the "Dynamic Attributes" associated with a content type', test_id: 'C13483' do
    test_rail_expected_steps(3)

    #Step1 Make a Post request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    test_rail_expected_result(1, "The user receives a 201 Created status")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    attribute_keys_create = V3::DynamicContent::AttributeKeys::Create.new(super_user_session.token, user_email, base_url, type, type_id, name, display_name)
    resp_code = attribute_keys_create.response.code
    resp_json = JSON.parse(attribute_keys_create.response.body)
    test_rail_result(1, "attribute_keys_create header: #{attribute_keys_create.response.headers}")
    test_rail_result(1, "attribute_keys_create body: #{attribute_keys_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating attribute keys associated with a content type response code: #{resp_code}", "pass")
    expect(attribute_keys_create.id.to_i).to be >=1
    expect(resp_json.dig('data','type')).to eq type
    expect(resp_json.dig('data','attributes','name')).to eq name
    expect(resp_json.dig('data','attributes','display_name')).to eq display_name
    test_rail_result(1, "new id of creating attribute keys associated with a content type in response: #{attribute_keys_create.id}", "pass")

    #Step2 Make a Post request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys with invalid params
    test_rail_expected_result(2, "The user receives a 422 Unprocessable Entity status")
    #Make a Post request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    name = ""
    attribute_keys_create = V3::DynamicContent::AttributeKeys::Create.new(super_user_session.token, user_email, base_url, type, type_id, name, display_name)
    resp_code = attribute_keys_create.response.code
    test_rail_result(2, "attribute_keys_create header: #{attribute_keys_create.response.headers}")
    test_rail_result(2, "attribute_keys_create body: #{attribute_keys_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating attribute keys associated with a content type response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a Post request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys with invalid params
    test_rail_expected_result(3, "User should receive a 403 status (Forbidden)")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys with invalid params
    attribute_keys_create = V3::DynamicContent::AttributeKeys::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, type, type_id, name, display_name)
    resp_code = attribute_keys_create.response.code
    test_rail_result(3, "attribute_keys_create header: #{attribute_keys_create.response.headers}")
    test_rail_result(3, "attribute_keys_create body: #{attribute_keys_create.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "creating attribute keys associated with a content type response code: #{resp_code}", "pass")
  end

end


