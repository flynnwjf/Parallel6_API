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


  it 'C12568 User can associate a nurse with a patient', test_id: 'C12568' do
      test_rail_expected_steps(1)

      #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/related_users
      test_rail_expected_result(1, "User can get 200 response and follower and followed user create relationship with each other")
      #Super User Session
      super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
      test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
      test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
      #Mobile User Session
      mobile_user_session_1 = V3::MobileUser::Session::Create.new(user_email_1, user_password_1, base_url, device_id_1)
      mobile_user_session_2 = V3::MobileUser::Session::Create.new(user_email_2, user_password_2, base_url, device_id_2)
      test_rail_result(1, "mobile_user_session_1 header: #{mobile_user_session_1.response.headers}")
      test_rail_result(1, "mobile_user_session_1 body: #{mobile_user_session_1.response.body}")
      test_rail_result(1, "mobile_user_session_2 header: #{mobile_user_session_2.response.headers}")
      test_rail_result(1, "mobile_user_session_2 body: #{mobile_user_session_2.response.body}")
      mobile_user_id_1 = mobile_user_session_1.mobile_user_id
      mobile_user_id_2 = mobile_user_session_2.mobile_user_id
      #Post request on {{protocol}}{{url}}/v3/related_users
      related_users_create = V3::RelatedUsers::Create.new(super_user_session.token, user_email, base_url, mobile_user_id_1, mobile_user_id_2)
      resp_code = related_users_create.response.code
      resp_json = JSON.parse(related_users_create.response.body)
      test_rail_result(1, "related_users_create header: #{related_users_create.response.headers}")
      test_rail_result(1, "related_users_create body: #{related_users_create.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(1, "creating related users response code: #{resp_code}", "pass")
      expect(resp_json.dig('data', 'relationships', 'followed_user', 'data', 'id') == "#{mobile_user_id_2}")
      test_rail_result(1, "relationship is created in response", "pass")
  end

end

