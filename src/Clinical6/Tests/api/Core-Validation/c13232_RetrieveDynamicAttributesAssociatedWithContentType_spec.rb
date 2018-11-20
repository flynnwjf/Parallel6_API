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
  let(:testname) { "dynamiccontent_contenttypes_attributekeys_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C13232 SDK User should be able to retrieve all the "Dynamic Attributes" associated with a content type', test_id: 'C13232' do
    test_rail_expected_steps(3)

    #Step1 Make a GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types/{{content_type_id}}/dynamic_content/attribute_keys
    test_rail_expected_result(1, "The user should receive a 200 and should see a dynamic_content__attribute_keys in the response")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types/{{content_type_id}}/dynamic_content/attribute_keys
    content_id = JSON.parse(V3::DynamicContent::ContentTypes::Index.new(super_user_session.token, user_email, base_url).response).dig("data", 0, "id")
    attribute_keys_show = V3::DynamicContent::ContentTypes::AttributeKeys::Show.new(super_user_session.token, user_email, base_url, content_id)
    resp_code = attribute_keys_show.response.code
    test_rail_result(1, "attribute_keys_show header: #{attribute_keys_show.response.headers}")
    test_rail_result(1, "attribute_keys_show body: #{attribute_keys_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting attribute keys associated with a content type response code: #{resp_code}", "pass")

    #Step2 Make a GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types/{{content_type_id}}/dynamic_content/attribute_keys with invalid id
    test_rail_expected_result(2, "The user should receive a 404 Not Found")
    #GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types/{{content_type_id}}/dynamic_content/attribute_keys
    invalid_id = test_data["invalid_id"]
    attribute_keys_show = V3::DynamicContent::ContentTypes::AttributeKeys::Show.new(super_user_session.token, user_email, base_url, invalid_id)
    resp_code = attribute_keys_show.response.code
    test_rail_result(2, "attribute_keys_show header: #{attribute_keys_show.response.headers}")
    test_rail_result(2, "attribute_keys_show body: #{attribute_keys_show.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "getting attribute keys associated with a content type response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types/{{content_type_id}}/dynamic_content/attribute_keys
    test_rail_expected_result(3, "User should receive a 403 status (Forbidden)")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types/{{content_type_id}}/dynamic_content/attribute_keys
    attribute_keys_show = V3::DynamicContent::ContentTypes::AttributeKeys::Show.new(unauthorized_user_session.token, unauthorized_user_email, base_url, content_id)
    resp_code = attribute_keys_show.response.code
    test_rail_result(3, "attribute_keys_show header: #{attribute_keys_show.response.headers}")
    test_rail_result(3, "attribute_keys_show body: #{attribute_keys_show.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "getting attribute keys associated with a content type response code: #{resp_code}", "pass")
  end

end


