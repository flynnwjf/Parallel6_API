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

  it 'C14274 The user should be able to add users to a certain user role', test_id: 'C14274' do
    test_rail_expected_steps(3)

    #Step1 Make a Get request on /v3/user_roles/
    test_rail_expected_result(1, "The user receives a list of user roles in the response")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    user_role = V3::UserRoles::Index.new(super_user_session.token, user_email, base_url)
    resp_code = user_role.response.code
    test_rail_result(1, "user_role body header: #{user_role.response.headers}")
    test_rail_result(1, "user_role session body: #{user_role.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "listing user roles response code: #{resp_code}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/invitation
    test_rail_expected_result(2, "The invitation email is sent out to the user")
    #POST request on {{protocol}}{{url}}/v3/mobile_users/invitation
    invitation_mobile_user = V3::MobileUser::Invitations::Create.new(super_user_session.token, user_email, base_url, email, member_type, first_name, last_name, user_role_id, site_id)
    resp_code = invitation_mobile_user.response.code
    test_rail_result(2, "invitation_mobile_user header: #{invitation_mobile_user.response.headers}")
    test_rail_result(2, "invitation_mobile_user body: #{invitation_mobile_user.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "mobile user invitation response code: #{resp_code}", "pass")
    mobile_user_id = invitation_mobile_user.id

    #Step3 The user makes a Get request on /v3/mobile_users/:id/profile
    test_rail_expected_result(3, "The User's profile is displayed")
    #Get request on /v3/mobile_users/:id/profile
    user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_session.token, user_email, base_url)
    resp_code = user_profile_show.response.code
    resp_json = JSON.parse(user_profile_show.response.body)
    test_rail_result(3, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(3, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "showing user profile response code: #{resp_code}", "pass")
    expect(resp_json.dig('included', 0, 'id')).to eq mobile_user_id
    test_rail_result(3, "user role is in user profile", "pass")
  end

end



