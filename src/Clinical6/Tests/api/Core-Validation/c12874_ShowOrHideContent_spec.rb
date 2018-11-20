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
#Test Info
  let(:testname) { "dynamiccontent_contents_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] }
  let(:visibility_status) { test_data["visibility_status"] }


  it 'C12874 SDK service should be able to show/hide content', test_id: 'C12874' do
    test_rail_expected_steps(3)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users/sessions
    test_rail_expected_result(1, "The user receives 200 OK response and identifies the mobile user id")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    resp_code = mobile_user_session.response.code
    expect(resp_code).to eq 200
    test_rail_result(1, "creating mobile_user_session response code: #{resp_code}", "pass")
    mobile_user_id = mobile_user_session.mobile_user_id

    #Step2 The user makes a Patch request on {{protocol}}{{url}}/v3/dynamic_content/contents/content_id
    test_rail_expected_result(2, "The user receives 200 response")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(2, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(2, "Super User session body: #{super_user_session.response.body}")
    #Patch request on {{protocol}}{{url}}/v3/dynamic_content/contents/content_id
    content_id = V3::DynamicContent::Contents::Create.new(super_user_session.token, user_email, base_url, type, id, mobile_user_id).id
    content_update = V3::DynamicContent::Contents::Update.new(super_user_session.token, user_email, base_url, content_id, type, title, visibility_status)
    resp_code = content_update.response.code
    test_rail_result(2, "content_update header: #{content_update.response.headers}")
    test_rail_result(2, "content_update body: #{content_update.response.body}")
    expect(resp_code).to eq 204
    test_rail_result(2, "updating content to hidden response code: #{resp_code}", "pass")

    #Step3 The user makes a Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/dynamic_content/contents
    test_rail_expected_result(3, "It returns a 200 status with the 'status' of dynamic content as 'hidden'")
    #Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/dynamic_content/contents
    mobileuser_dynamiccontent = V3::MobileUser::DynamicContent::Contents::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_dynamiccontent.response.code
    resp_json = JSON.parse(mobileuser_dynamiccontent.response.body)
    test_rail_result(3, "mobileuser_dynamiccontent header: #{mobileuser_dynamiccontent.response.headers}")
    test_rail_result(3, "mobileuser_dynamiccontent body: #{mobileuser_dynamiccontent.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting mobileuser dynamic content response code: #{resp_code}", "pass")
    status = resp_json['data'].any? { |s| s.dig('attributes','visibility_status') == "hidden"}
    expect(status).to be true
    test_rail_result(3, "mobileuser_dynamiccontent hidden status in response: #{status}", "pass")
  end

end

