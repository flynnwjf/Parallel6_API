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
  let(:email) { "TestEmail" + DateTime.now.strftime('_%Q').to_s + "@mailinator.com" }
  let(:member_type) { test_data["member_type"] }
  let(:first_name) { "FirstName" + Time.new.strftime("%Y%m%d") }
  let(:last_name) { "LastName" + Time.new.strftime("%Y%m%d") }
  let(:user_role_id) { test_data["user_role_id"] }
  let(:site_id) { test_data["site_id"] }
  let(:updated_first_name) { "FirstName " + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:updated_last_name) { "LastName " + Time.new.strftime("%Y%m%d%H%M%S") }

  it 'C13738 The system will automatically invalidate sessions that are idle forcing the user to re-authenticate', test_id: 'C13738' do
    test_rail_expected_steps(5)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/users/sessions
    test_rail_expected_result(1, "The user receives a response 201 Created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    resp_code = super_user_session.response.code
    expect(resp_code).to eq 201
    test_rail_result(1, "user session response code: #{resp_code}", "pass")
    user_token = super_user_session.token
    test_rail_result(1, "user token in response: #{user_token}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/invitation
    test_rail_expected_result(2, "The user receives a response 200 OK and creates the mobile_user_id")
    #POST request on {{protocol}}{{url}}/v3/mobile_users/invitation
    invitation_mobile_user = V3::MobileUser::Invitations::Create.new(user_token, user_email, base_url, email, member_type, first_name, last_name, user_role_id, site_id)
    resp_code = invitation_mobile_user.response.code
    test_rail_result(2, "invitation_mobile_user header: #{invitation_mobile_user.response.headers}")
    test_rail_result(2, "invitation_mobile_user body: #{invitation_mobile_user.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "mobile user invitation response code: #{resp_code}", "pass")
    mobile_user_id = invitation_mobile_user.id
    test_rail_result(2, "new mobile user id in response: #{mobile_user_id}", "pass")

    #Step3 The user makes a Get request on /v3/mobile_users/:id/profile
    test_rail_expected_result(3, "The user is able to view the mobile user's profile")
    #Get request on /v3/mobile_users/:id/profile
    user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id, user_token, user_email, base_url)
    resp_code = user_profile_show.response.code
    test_rail_result(3, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(3, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "showing user profile response code: #{resp_code}", "pass")

    #Step4 The user makes a Get request on {{protocol}}{{url}}/v3/users/sessions after long time
    test_rail_expected_result(4, "The user receives a 401 Unauthorized response showing the session is expired")
    sleep(1000)
    #Get request on {{protocol}}{{url}}/v3/users/sessions after long time
    session_show = V3::Users::Session::Show.new(user_token, user_email, base_url)
    resp_code = session_show.response.code
    test_rail_result(4, "session_show header: #{session_show.response.headers}")
    test_rail_result(4, "session_show body: #{session_show.response.body}")
    expect(resp_code).to eq 401
    test_rail_result(4, "showing user session response code: #{resp_code}", "pass")

    #Step5 The user makes a Get request on /v3/mobile_users/:id/profile
    test_rail_expected_result(5, "The user receives a response 401 response")
    #Get request on /v3/mobile_users/:id/profile
    user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id, user_token, user_email, base_url)
    resp_code = user_profile_show.response.code
    test_rail_result(5, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(5, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 401
    test_rail_result(5, "showing updated user profile response code: #{resp_code}", "pass")
  end

end



