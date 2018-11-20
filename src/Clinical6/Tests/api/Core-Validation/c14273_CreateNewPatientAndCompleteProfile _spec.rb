require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "mobileuser_invitations_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:email) { "TestEmail" + DateTime.now.strftime('_%Q').to_s + "@parallel6.mailinator.com" }
  let(:member_type) { test_data["member_type"] }
  let(:first_name) { "FirstName" + Time.new.strftime("%Y%m%d") }
  let(:last_name) { "LastName" + Time.new.strftime("%Y%m%d") }
  let(:user_role_id) { test_data["user_role_id"] }
  let(:site_id) { test_data["site_id"] }
  let(:updated_first_name) { "FirstName " + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:updated_last_name) { "LastName " + Time.new.strftime("%Y%m%d%H%M%S") }

  it 'C14273 A User should be able to create/setup new patients in the system and complete the patient\'s profile.', test_id: 'C14273' do
    test_rail_expected_steps(4)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/invitation
    test_rail_expected_result(1, "User should be able to create a new mobile user")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/mobile_users/invitation
    invitation_mobile_user = V3::MobileUser::Invitations::Create.new(super_user_session.token, user_email, base_url, email, member_type, first_name, last_name, user_role_id, site_id)
    resp_code = invitation_mobile_user.response.code
    test_rail_result(1, "invitation_mobile_user header: #{invitation_mobile_user.response.headers}")
    test_rail_result(1, "invitation_mobile_user body: #{invitation_mobile_user.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "mobile user invitation response code: #{resp_code}", "pass")
    mobile_user_id = invitation_mobile_user.id
    test_rail_result(1, "new mobile user id in response: #{mobile_user_id}", "pass")

    #Step2 The user makes a Get request on /v3/mobile_users/:id/profile
    test_rail_expected_result(2, "The Profile of the created user is displayed")
    #Get request on /v3/mobile_users/:id/profile
    user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_session.token, user_email, base_url)
    resp_code = user_profile_show.response.code
    test_rail_result(2, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(2, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "showing user profile response code: #{resp_code}", "pass")

    #Step3 The user makes a Patch request on /v3/mobile_users/:id/profile
    test_rail_expected_result(3, "User should be able to see updated information of the user that is just created")
    #Patch request on /v3/mobile_users/:id/profile
    mobileuser_profile_update = V3::MobileUser::Profile::Update.new(mobile_user_id, super_user_session.token, user_email, base_url, updated_first_name, updated_last_name)
    resp_code = mobileuser_profile_update.response.code
    resp_json = JSON.parse(mobileuser_profile_update.response.body)
    test_rail_result(3, "mobileuser_profile_update header: #{mobileuser_profile_update.response.headers}")
    test_rail_result(3, "mobileuser_profile_update body: #{mobileuser_profile_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "updating user profile response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'first_name')).to eq updated_first_name
    expect(resp_json.dig('data', 'attributes', 'last_name')).to eq updated_last_name
    test_rail_result(3, "updating FN and LN of user profile in response: #{updated_first_name} and #{updated_last_name}", "pass")

    #Step4 The user makes a Get request on /v3/mobile_users/:id/profile
    test_rail_expected_result(4, "The updated profile of the created user is displayed")
    #Get request on /v3/mobile_users/:id/profile
    user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_session.token, user_email, base_url)
    resp_code = user_profile_show.response.code
    resp_json = JSON.parse(user_profile_show.response.body)
    test_rail_result(4, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(4, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(4, "showing updated user profile response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'first_name')).to eq updated_first_name
    expect(resp_json.dig('data', 'attributes', 'last_name')).to eq updated_last_name
    test_rail_result(4, "updated FN and LN of user profile in response: #{updated_first_name} and #{updated_last_name}", "pass")
  end

end



