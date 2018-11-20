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
  let(:mobile_user_email) { mobile_user["email"] }
  let(:mobile_user_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
#Preconditions
  let(:pre_testname) { "dynamiccontent_contents_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:content_type_id) { pre_test_data["content_type_id"] }
#Test Info
  let(:testname) { "dynamiccontent_contents_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C13171 - API Client able to retrieve a specific Dynamic Content', test_id: 'C13171' do
    test_rail_expected_steps(2)

    #Step1 In the GET tool V3, the Admin user go to DynamicContent > Contents > Show.
    test_rail_expected_result(1, "200 response with GET request with dynamic_content/contents/")

    new_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "response header: #{new_session.response.headers}")
    test_rail_result(1, "response body: #{new_session.response.body}")
    expect(new_session.response.code).to eq 201
    mobile_user_id = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id
    contents_create = V3::DynamicContent::Contents::Create.new(new_session.token, user_email, base_url, type, content_type_id, mobile_user_id)
    test_rail_result(1, "contents_create header: #{contents_create.response.headers}")
    test_rail_result(1, "contents_create body: #{contents_create.response.body}")
    expect(contents_create.response.code).to eq 201

    contents_index = V3::DynamicContent::Contents::Index.new(new_session.token, user_email, base_url)
    test_rail_result(1, "contents_index header: #{contents_index.response.headers}")
    test_rail_result(1, "contents_index body: #{contents_index.response.body}")
    expect(JSON.parse(contents_index.response.body).dig("data", 0, "type")).not_to eq nil
    test_rail_result(1, "type: #{JSON.parse(contents_index.response.body).dig("data", 0, "type")} was present")
    expect(contents_index.response.code).to eq 200
    #cleanup
    expect(V3::DynamicContent::Contents::Destroy.new(new_session.token, user_email, base_url, contents_create.id).response.code).to eq 204
    test_rail_result(1, "contents_index response code: #{contents_index.response.code}", "pass")

    #Step2 Using an invalid user read the dynamic content (a user that is not an admin or superuser), then do the GET request
    test_rail_expected_result(2, "401 response")

    env_user = DataHandler.get_env_user(env_info, :unauthorized_user)
    user_email = env_user["email"]
    user_password = env_user["password"]
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(2, "User session body header: #{super_user_session.response.headers}")
    test_rail_result(2, "User session body: #{super_user_session.response.body}")

    contents_index = V3::DynamicContent::Contents::Index.new(new_session.token, user_email, base_url)
    test_rail_result(2, "contents_index header: #{contents_index.response.headers}")
    test_rail_result(2, "contents_index body: #{contents_index.response.body}")
    expect(contents_index.response.code).to eq 401
    test_rail_result(2, "contents_index response code: #{contents_index.response.code}", "pass")


  end

end



