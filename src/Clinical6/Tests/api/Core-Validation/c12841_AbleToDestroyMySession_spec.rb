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


  it 'C12841 Mobile User should be able to destroy "my" session so that he can ensure that no one can continue using my authentication token', test_id: 'C12841' do
      test_rail_expected_steps(8)

      #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(1, "201 response with access token for device, note the access_token")
      #Mobile User Session
      mobile_user_session_1 = V3::MobileUser::Session::Create.new(user_email_1, user_password_1, base_url, device_id_1)
      #POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      resp_code_1 = mobile_user_session_1.response.code
      test_rail_result(1, "mobile_user_session_1 header: #{mobile_user_session_1.response.headers}")
      test_rail_result(1, "mobile_user_session_1 body: #{mobile_user_session_1.response.body}")
      expect(resp_code_1).to eq 200
      test_rail_result(1, "creating mobile_user_session 1 response code: #{resp_code_1}", "pass")
      token1 = mobile_user_session_1.token

      #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(2, "201 response with access token for device, note the access_token")
      #Mobile User Session
      mobile_user_session_2 = V3::MobileUser::Session::Create.new(user_email_2, user_password_2, base_url, device_id_2)
      #POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      resp_code_2 = mobile_user_session_2.response.code
      test_rail_result(2, "mobile_user_session_2 header: #{mobile_user_session_2.response.headers}")
      test_rail_result(2, "mobile_user_session_2 body: #{mobile_user_session_2.response.body}")
      expect(resp_code_2).to eq 200
      test_rail_result(2, "creating mobile_user_session 2 response code: #{resp_code_2}", "pass")
      token2 = mobile_user_session_2.token

      #Step3 The user makes a Get request on {{protocol}}{{url}}/v3/mobile_users/sessions/show
      test_rail_expected_result(3, "200 response . With entries for both devices from previous steps showing the device id and access token, as well as correct dates for when the sessions were created")
      #Get request on {{protocol}}{{url}}/v3/mobile_users/sessions/show
      mobileuser_1_session_show = V3::MobileUser::Session::Show.new(base_url, token1)
      resp_code = mobileuser_1_session_show.response.code
      test_rail_result(3, "mobileuser_1_session_show header: #{mobileuser_1_session_show.response.headers}")
      test_rail_result(3, "mobileuser_1_session_show body: #{mobileuser_1_session_show.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(3, "showing mobile user session response code: #{resp_code}", "pass")

      #Step4 The user makes a Delete request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(4, "204 response without body content in response")
      #Delete request on {{protocol}}{{url}}/v3/mobile_users/sessions
      mobileuser_1_session_delete = V3::MobileUser::Session::Delete.new(base_url, token1)
      resp_code = mobileuser_1_session_delete.response.code
      test_rail_result(4, "mobileuser_1_session_delete header: #{mobileuser_1_session_delete.response.headers}")
      test_rail_result(4, "mobileuser_1_session_delete body: #{mobileuser_1_session_delete.response.body}")
      expect(resp_code).to eq 204
      test_rail_result(4, "deleting mobile user session response code: #{resp_code}", "pass")

      #Step5 The user makes a Get request on {{protocol}}{{url}}/v3/mobile_users/sessions/show
      test_rail_expected_result(5, "200 response . Entry with access token only for only <Device2> present.")
      #Get request on {{protocol}}{{url}}/v3/mobile_users/sessions/show
      mobileuser_2_session_show = V3::MobileUser::Session::Show.new(base_url, token2)
      resp_code = mobileuser_2_session_show.response.code
      test_rail_result(5, "mobileuser_2_session_show header: #{mobileuser_2_session_show.response.headers}")
      test_rail_result(5, "mobileuser_2_session_show body: #{mobileuser_2_session_show.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(5, "showing mobile user session response code: #{resp_code}", "pass")

      #Step6 The user makes a Delete request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(6, "401 status response with Authentication Failed type error message")
      #Delete request on {{protocol}}{{url}}/v3/mobile_users/sessions
      mobileuser_1_session_delete = V3::MobileUser::Session::Delete.new(base_url, token1)
      resp_code = mobileuser_1_session_delete.response.code
      test_rail_result(6, "mobileuser_1_session_delete header: #{mobileuser_1_session_delete.response.headers}")
      test_rail_result(6, "mobileuser_1_session_delete body: #{mobileuser_1_session_delete.response.body}")
      expect(resp_code).to eq 401
      test_rail_result(6, "deleting mobile user session response code: #{resp_code}", "pass")

      #Step7 The user makes a Delete request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(7, "401 status response with Authentication Failed type error message")
      #Delete request on {{protocol}}{{url}}/v3/mobile_users/sessions
      token1 = "0"
      mobileuser_1_session_delete = V3::MobileUser::Session::Delete.new(base_url, token1)
      resp_code = mobileuser_1_session_delete.response.code
      test_rail_result(7, "mobileuser_1_session_delete header: #{mobileuser_1_session_delete.response.headers}")
      test_rail_result(7, "mobileuser_1_session_delete body: #{mobileuser_1_session_delete.response.body}")
      expect(resp_code).to eq 401
      test_rail_result(7, "deleting mobile user session response code: #{resp_code}", "pass")

      #Step8 The user makes a Delete request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(8, "401 status response with Authentication Failed type error message")
      #Delete request on {{protocol}}{{url}}/v3/mobile_users/sessions
      token1 = "99999999999999999999999999999999999999999"
      mobileuser_1_session_delete = V3::MobileUser::Session::Delete.new(base_url, token1)
      resp_code = mobileuser_1_session_delete.response.code
      test_rail_result(8, "mobileuser_1_session_delete header: #{mobileuser_1_session_delete.response.headers}")
      test_rail_result(8, "mobileuser_1_session_delete body: #{mobileuser_1_session_delete.response.body}")
      expect(resp_code).to eq 401
      test_rail_result(8, "deleting mobile user session response code: #{resp_code}", "pass")
  end

end

