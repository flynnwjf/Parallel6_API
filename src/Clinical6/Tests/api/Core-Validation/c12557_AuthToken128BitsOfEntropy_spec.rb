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
  let(:testname) { "user_sessions_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C12557 Users authorization tokens should be sufficiently random and use at least 128 bits of entropy', test_id: 'C12557' do
    test_rail_expected_steps(2)

    #Step1 Make a Post request on {{protocol}}{{url}}/v3/users/session with valid user credentials
    test_rail_expected_result(1, "It returns 201 response and includes an 'authentication_token' comprised of 64 characters.")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "User session body: #{super_user_session.response.body}")
    expect(super_user_session.response.code).to eq 201
    expect(super_user_session.token.length).to be 64
    test_rail_result(1, "user session response code: #{super_user_session.response.code}")
    test_rail_result(1, "user session token: #{super_user_session.token}")
    test_rail_result(1, "user session token length: #{super_user_session.token.length}", "pass")

    #Step2 Make a Post request on {{protocol}}{{url}}/v3/mobile_users/sessions with valid mobile user credentials
    test_rail_expected_result(2, "It returns 200 response and includes an 'authentication_token' comprised of 64 characters.")
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(2, "mobile user session body header: #{mobile_user_session.response.headers}")
    test_rail_result(2, "mobile user session body: #{mobile_user_session.response.body}")
    expect(mobile_user_session.response.code).to eq 200
    expect(mobile_user_session.token.length).to be 64
    test_rail_result(2, "mobile user session response code: #{mobile_user_session.response.code}")
    test_rail_result(2, "mobile user session token: #{mobile_user_session.token}")
    test_rail_result(2, "mobile user session token length: #{mobile_user_session.token.length}", "pass")
  end
end

