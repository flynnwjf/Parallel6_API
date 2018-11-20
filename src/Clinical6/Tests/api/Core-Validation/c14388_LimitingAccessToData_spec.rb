require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
  let(:env_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:user_email_2) { env_user["email"] }
  let(:user_password_2) { env_user["password"] }
  let(:device_id_2) { env_user["device_id"] }
  let(:user_email_1) { env_user["email_1"] }
  let(:user_password_1) { env_user["password_1"] }
  let(:device_id_1) { env_user["device_id_1"] }
#Test Info
  let(:testname) { "mobileuser_sessions_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C14388 Support for: limiting access to data that do not belong to mobile users associate to a certain User', test_id: 'C14388' do
      test_rail_expected_steps(3)

      #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(1, "User can get mobile user 1 id and token")
      #Mobile User Session
      mobile_user_session_1 = V3::MobileUser::Session::Create.new(user_email_1, user_password_1, base_url, device_id_1)
      #POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      resp_code_1 = mobile_user_session_1.response.code
      test_rail_result(1, "mobile_user_session_1 header: #{mobile_user_session_1.response.headers}")
      test_rail_result(1, "mobile_user_session_1 body: #{mobile_user_session_1.response.body}")
      expect(resp_code_1).to eq 200
      test_rail_result(1, "creating mobile_user_session 1 response code: #{resp_code_1}", "pass")
      mobile_user_id_1 = mobile_user_session_1.mobile_user_id

      #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(2, "User can get mobile user 2 id and token")
      #Mobile User Session
      mobile_user_session_2 = V3::MobileUser::Session::Create.new(user_email_2, user_password_2, base_url, device_id_2)
      #POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      resp_code_2 = mobile_user_session_2.response.code
      test_rail_result(2, "mobile_user_session_2 header: #{mobile_user_session_2.response.headers}")
      test_rail_result(2, "mobile_user_session_2 body: #{mobile_user_session_2.response.body}")
      expect(resp_code_2).to eq 200
      test_rail_result(2, "creating mobile_user_session 2 response code: #{resp_code_2}", "pass")
      mobile_user_id_2 = mobile_user_session_2.mobile_user_id

      #Step3 The user makes a Get request on /v3/mobile_users/:mobile_user_id/profile with mobile user 1 token but mobile user 2 id
      test_rail_expected_result(3, "User can get 403 response with message Access denied")
      #Get request on /v3/mobile_users/:mobile_user_id/profile with mobile user 1 token but mobile user 2 id
      user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id_2, mobile_user_session_1.token,"", base_url)
      resp_code = user_profile_show.response.code
      test_rail_result(3, "user_profile_show header: #{user_profile_show.response.headers}")
      test_rail_result(3, "user_profile_show body: #{user_profile_show.response.body}")
      expect(resp_code).to eq 403
      test_rail_result(3, "listing mobile user profile response code: #{resp_code}", "pass")
  end

end

