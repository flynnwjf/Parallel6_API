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

  it 'C14206 Allows user to manually assign a unique System ID for new patients added to the System.', test_id: 'C14206' do
    test_rail_expected_steps(2)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/invitation
    test_rail_expected_result(1, "User should be able to assign a System ID to the email he used to add a new mobile user")
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
    test_rail_result(1, "unique mobile user id in response: #{mobile_user_id}", "pass")

    #Step2 The user makes a Get request on /v3/mobile_users/:id/profile
    test_rail_expected_result(2, "The user can get 200 OK response")
    #Get request on /v3/mobile_users/:id/profile
    user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_session.token, user_email, base_url)
    resp_code = user_profile_show.response.code
    resp_json = JSON.parse(user_profile_show.response.body)
    test_rail_result(2, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(2, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "showing user profile response code: #{resp_code}", "pass")
    expect(resp_json.dig('included', 0, 'id')).to eq mobile_user_id
    test_rail_result(2, "unique mobile user id is shown in user profile: #{resp_json.dig('included', 0, 'id')}", "pass")
  end

end



