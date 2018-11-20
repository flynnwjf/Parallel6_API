require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_email) { mobile_user["email"] }
  let(:mobile_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:testname) { "dynamiccontent_contents_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:content_type_id) { test_data["content_type_id"] }
  let(:invalid_id) { test_data["invalid_id"] }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] }


  it 'C12944 Admin User should be able to delete a content', test_id: 'C12944' do
    test_rail_expected_steps(4)

    #Step1 The user makes a Post request on /v3/dynamic_content/contents
    test_rail_expected_result(1, "201 response code with created content id")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    mobile_user_id = mobile_user_session.mobile_user_id
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on /v3/dynamic_content/contents
    contents_create = V3::DynamicContent::Contents::Create.new(super_user_session.token, user_email, base_url, type, content_type_id, mobile_user_id)
    content_id = contents_create.id
    resp_code = contents_create.response.code
    test_rail_result(1, "contents_create header: #{contents_create.response.headers}")
    test_rail_result(1, "contents_create body: #{contents_create.response.body}")
    test_rail_result(1, "contents_create response code: #{resp_code}", "pass")

    #Step2 The user makes a DELETE request on {{protocol}}{{url}}/v3/dynamic_content/contents/:id
    test_rail_expected_result(2, "User receives a 204 response, and the content and its dynamic values are deleted.")
    content_delete = V3::DynamicContent::Contents::Destroy.new(super_user_session.token, user_email, base_url, content_id)
    test_rail_result(2, "content_delete header: #{content_delete.response.headers}")
    test_rail_result(2, "content_delete body: #{content_delete.response.body}")
    resp_code = content_delete.response.code
    expect(content_delete.response.code).to eq 204
    test_rail_result(2, "content_delete response code: #{resp_code}", "pass")

    #Step3 The user makes a DELETE request on {{protocol}}{{url}}/v3/dynamic_content/contents/:id with invalid id
    test_rail_expected_result(3, "The response returns 404 Record Not Found")
    content_delete = V3::DynamicContent::Contents::Destroy.new(super_user_session.token, user_email, base_url, invalid_id)
    test_rail_result(3, "content_delete header: #{content_delete.response.headers}")
    test_rail_result(3, "content_delete body: #{content_delete.response.body}")
    resp_code = content_delete.response.code
    expect(content_delete.response.code).to eq 404
    test_rail_result(3, "content_delete response code: #{resp_code}", "pass")

    #Step4 The user makes a DELETE request on {{protocol}}{{url}}/v3/dynamic_content/contents/:id
    test_rail_expected_result(4, "The user receives a 403 forbidden response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    content_delete = V3::DynamicContent::Contents::Destroy.new(unauthorized_user_session.token, unauthorized_user_email, base_url, content_type_id)
    test_rail_result(4, "content_delete header: #{content_delete.response.headers}")
    test_rail_result(4, "content_delete body: #{content_delete.response.body}")
    resp_code = content_delete.response.code
    expect(content_delete.response.code).to eq 403
    test_rail_result(4, "content_delete response code: #{resp_code}", "pass")
  end

end