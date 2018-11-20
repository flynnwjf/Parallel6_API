require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_email) { mobile_user["email"] }
  let(:mobile_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
#Test Info
  let(:testname) { "dynamiccontent_attributekeys_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:name) { test_data["name"] + DateTime.now.strftime('_%Q').to_s }
  let(:display_name) { test_data["display_name"] }


  it 'C13486 SDK User should be able to delete existing attributes', test_id: 'C13486' do
    test_rail_expected_steps(4)

    #Step1 Make a GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types
    test_rail_expected_result(1, "The user should see the content type list and 200 OK status")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types
    content_types_index = V3::DynamicContent::ContentTypes::Index.new(super_user_session.token, user_email, base_url)
    resp_code = content_types_index.response.code
    type_id = content_types_index.id
    test_rail_result(1, "content_types_index header: #{content_types_index.response.headers}")
    test_rail_result(1, "content_types_index body: #{content_types_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "listing content types response code: #{resp_code}", "pass")

    #Step2 Post request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    test_rail_expected_result(2, "The user should create the dynamic content attribute key and its association with content types and 201 OK status")
    #Post request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys
    attribute_keys_create = V3::DynamicContent::AttributeKeys::Create.new(super_user_session.token, user_email, base_url, type, type_id, name, display_name)
    resp_code = attribute_keys_create.response.code
    key_id = attribute_keys_create.id
    test_rail_result(2, "attribute_keys_create header: #{attribute_keys_create.response.headers}")
    test_rail_result(2, "attribute_keys_create body: #{attribute_keys_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(2, "creating attribute keys response code: #{resp_code}", "pass")

    #Step3 Make a DELETE request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys/{dynamic_content_attribute_keys_id}
    test_rail_expected_result(3, "The user should receive a 204 No Content status and an empty response")
    #DELETE request on {{protocol}}{{url}}/v3/dynamic_content/attribute_keys/{dynamic_content_attribute_keys_id}
    attribute_keys_destroy = V3::DynamicContent::AttributeKeys::Destroy.new(super_user_session.token, user_email, base_url, key_id)
    resp_code = attribute_keys_destroy.response.code
    test_rail_result(3, "attribute_keys_destroy header: #{attribute_keys_destroy.response.headers}")
    test_rail_result(3, "attribute_keys_destroy body: #{attribute_keys_destroy.response.body}")
    expect(resp_code).to eq 204
    test_rail_result(3, "deleting attribute key response code: #{resp_code}", "pass")

    #Step4 GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types/{content_type_id}/dynamic_content/attribute_keys
    test_rail_expected_result(4, "The user should receive a 200 OK and no content")
    #GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types/{content_type_id}/dynamic_content/attribute_keys
    attribute_keys = V3::DynamicContent::ContentTypes::AttributeKeys::Show.new(super_user_session.token, user_email, base_url, type_id)
    resp_code = attribute_keys.response.code
    key_id = attribute_keys.id
    test_rail_result(4, "attribute_keys header: #{attribute_keys.response.headers}")
    test_rail_result(4, "attribute_keys body: #{attribute_keys.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(4, "listing attribute keys response code: #{resp_code}", "pass")
    expect(JSON.parse(attribute_keys.response.body)["data"].size < 1)
    test_rail_result(4, "no content in response", "pass")
  end

end


