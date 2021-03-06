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


  it 'C14709 Allow user to invite a patient companion with an email address', test_id: 'C14709' do
      test_rail_expected_steps(6)

      #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(1, "A new user is created with a mobile_user_id1")
      #Mobile User Session
      mobile_user_session_1 = V3::MobileUser::Session::Create.new(user_email_1, user_password_1, base_url, device_id_1)
      #POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      resp_code_1 = mobile_user_session_1.response.code
      test_rail_result(1, "mobile_user_session_1 header: #{mobile_user_session_1.response.headers}")
      test_rail_result(1, "mobile_user_session_1 body: #{mobile_user_session_1.response.body}")
      expect(resp_code_1).to eq 200
      test_rail_result(1, "creating mobile_user_session 1 response code: #{resp_code_1}", "pass")
      mobile_user_id_1 = mobile_user_session_1.mobile_user_id

      #Step2 The user makes a Get request on /v3/mobile_users/:id/profile
      test_rail_expected_result(2, "The users profile is displayed")
      #Super User Session
      super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
      test_rail_result(2, "super_user_session header: #{super_user_session.response.headers}")
      test_rail_result(2, "super_user_session body: #{super_user_session.response.body}")
      #Get request on /v3/mobile_users/:id/profile
      user_profile_1_show = V3::MobileUser::Profile::Show.new(mobile_user_id_1, super_user_session.token, user_email, base_url)
      resp_code = user_profile_1_show.response.code
      resp_json = JSON.parse(user_profile_1_show.response.body)
      test_rail_result(2, "user_profile_1_show header: #{user_profile_1_show.response.headers}")
      test_rail_result(2, "user_profile_1_show body: #{user_profile_1_show.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(2, "showing user 1 profile response code: #{resp_code}", "pass")
      expect(resp_json.dig('included', 0, 'id')).to eq mobile_user_id_1

      #Step3 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(3, "A new user is created with a mobile_user_id2")
      #Mobile User Session
      mobile_user_session_2 = V3::MobileUser::Session::Create.new(user_email_2, user_password_2, base_url, device_id_2)
      #POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
      resp_code_2 = mobile_user_session_2.response.code
      test_rail_result(3, "mobile_user_session_2 header: #{mobile_user_session_2.response.headers}")
      test_rail_result(3, "mobile_user_session_2 body: #{mobile_user_session_2.response.body}")
      expect(resp_code_2).to eq 200
      test_rail_result(3, "creating mobile_user_session 2 response code: #{resp_code_2}", "pass")
      mobile_user_id_2 = mobile_user_session_2.mobile_user_id

      #Step4 The user makes a Get request on /v3/mobile_users/:id/profile
      test_rail_expected_result(4, "The users profile is displayed")
      #Get request on /v3/mobile_users/:id/profile
      user_profile_2_show = V3::MobileUser::Profile::Show.new(mobile_user_id_2, super_user_session.token, user_email, base_url)
      resp_code = user_profile_2_show.response.code
      resp_json = JSON.parse(user_profile_2_show.response.body)
      test_rail_result(4, "user_profile_2_show header: #{user_profile_2_show.response.headers}")
      test_rail_result(4, "user_profile_2_show body: #{user_profile_2_show.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(4, "showing user 2 profile response code: #{resp_code}", "pass")
      expect(resp_json.dig('included', 0, 'id')).to eq mobile_user_id_2

      #Step5 The user makes a Post request on {{protocol}}{{url}}/v3/related_users
      test_rail_expected_result(5, "The user receives 200 OK")
      #Post request on {{protocol}}{{url}}/v3/related_users
      related_users_create = V3::RelatedUsers::Create.new(super_user_session.token, user_email, base_url, mobile_user_id_1, mobile_user_id_2)
      resp_code = related_users_create.response.code
      test_rail_result(5, "related_users_create header: #{related_users_create.response.headers}")
      test_rail_result(5, "related_users_create body: #{related_users_create.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(5, "creating related users response code: #{resp_code}", "pass")

      #Step6 The user makes a GET request on {{protocol}{{url}}/v3/mobile_users/{{mobile_user_id1}}/related_users
      test_rail_expected_result(6, "It is displayed with the relationship defined with mobile_user_id2")
      #GET request on {{protocol}{{url}}/v3/mobile_users/{{mobile_user_id1}}/related_users
      mobileuser_relatedusers = V3::MobileUser::RelatedUsers::Show.new(super_user_session.token, user_email, base_url, mobile_user_id_1)
      resp_code = mobileuser_relatedusers.response.code
      resp_json = JSON.parse(mobileuser_relatedusers.response.body)
      test_rail_result(6, "mobileuser_relatedusers header: #{mobileuser_relatedusers.response.headers}")
      test_rail_result(6, "mobileuser_relatedusers body: #{mobileuser_relatedusers.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(6, "listing mobile user related user response code: #{resp_code}", "pass")
      related = resp_json['data'].any? { |user| user.dig('relationships', 'followed_user', 'data', 'id') == "#{mobile_user_id_2}"}
      expect(related).to be true
      test_rail_result(6, "mobile user related user in response: #{related}", "pass")
  end

end

