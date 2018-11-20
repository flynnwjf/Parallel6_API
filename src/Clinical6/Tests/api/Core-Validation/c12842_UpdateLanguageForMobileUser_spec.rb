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
#Test Info
  let(:testname) { "mobileuser_update_language" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:language_id) { test_data["language_id"] }

  it 'C12842 User should be able to update the language associated with a Web/Mobile User profile', test_id: 'C12842' do
    test_rail_expected_steps(3)

    #Step1 Make a Patch request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/profile with valid mobile user and the language that needs to update
    test_rail_expected_result(1, "It returns 200 response and the profile updates to the specified language")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(1, "mobile_user_session header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "mobile_user_session body: #{mobile_user_session.response.body}")
    update_language = V3::MobileUser::Profile::UpdateLanguage.new(mobile_user_session.id, super_user_session.token, user_email, base_url, language_id)
    test_rail_result(1, "update_language header: #{update_language.response.headers}")
    test_rail_result(1, "update_language body: #{update_language.response.body}")
    resp_json = JSON.parse(update_language.response)
    expect(update_language.response.code).to eq 200
    test_rail_result(1, "update_language response code: #{update_language.response.code}")
    expect(resp_json.dig('data', 'relationships', 'language', 'data', 'id')).to eq language_id
    test_rail_result(1, "updating language id: #{language_id}", "pass")

    #Step2 Make a Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/profile with mobile user on step 1
    test_rail_expected_result(2, "It returns 200 response and the language in profile is updated")
    user_profile = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_session.token, user_email, base_url)
    test_rail_result(2, "user_profile header: #{user_profile.response.headers}")
    test_rail_result(2, "user_profile body: #{user_profile.response.body}")
    resp_json = JSON.parse(user_profile.response.body)
    expect(user_profile.response.code).to eq 200
    test_rail_result(2, "user_profile response code: #{user_profile.response.code}")
    expect(resp_json.dig('data', 'relationships', 'language', 'data', 'id')).to eq language_id
    test_rail_result(2, "user profile response code: #{user_profile.response.code}", "pass")

    #Step3 Make a Patch request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/profile with unauthorized user and the language that needs to update
    test_rail_expected_result(3, "It returns 403 Forbidden")
    env_user = DataHandler.get_env_user(env_info, :unauthorized_user)
    user_email = env_user["email"]
    user_password = env_user["password"]
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(3, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(3, "Super User session body: #{super_user_session.response.body}")
    update_language = V3::MobileUser::Profile::UpdateLanguage.new( mobile_user_session.mobile_user_id, super_user_session.token, user_email, base_url, language_id)
    test_rail_result(3, "update_language header: #{update_language.response.headers}")
    test_rail_result(3, "update_language body: #{update_language.response.body}")
    expect(update_language.response.code).to eq 403
    test_rail_result(3, "update_language response code: #{update_language.response.code}", "pass")
  end

end
