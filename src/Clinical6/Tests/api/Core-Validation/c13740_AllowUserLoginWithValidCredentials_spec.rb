require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_email) { mobile_user["email"] }
  let(:mobile_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
#Test Info
  let(:testname) { "mobileuser_profile_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C13740 System should allow the user to login with valid credentials', test_id: 'C13740' do
    test_rail_expected_steps(2)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/users/sessions
    test_rail_expected_result(1, "The user is able to create a session.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #POST request on {{protocol}}{{url}}/v3/users/sessions
    resp_code = super_user_session.response.code
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating user session response code: #{resp_code}", "pass")

    #Step2 The user makes a Get request on /v3/mobile_users/:id/profile
    test_rail_expected_result(2, "The user is able to view the mobile user's profile.")
    #Get request on /v3/mobile_users/:id/profile
    user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_session.token, user_email, base_url)
    resp_code = user_profile_show.response.code
    resp_json = JSON.parse(user_profile_show.response.body)
    test_rail_result(2, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(2, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "showing user profile response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'type')).to eq "profiles"
    test_rail_result(2, "showing user profile in response", "pass")
  end

end

