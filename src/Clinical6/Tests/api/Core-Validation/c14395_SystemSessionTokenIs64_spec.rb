require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }

  it 'c14395 - The System should ensure that all passwords, PINs, shared secrets, and other authentication information is encrypted in storage and transmission', test_id: 'C14395' do
    test_rail_expected_steps(1)

    #Step1 Make a Post request on /v3/users/session
    test_rail_expected_result(1, "New session is created for user with new authentication token which length is 64")
    new_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "response header: #{new_session.response.headers}")
    test_rail_result(1, "response body: #{new_session.response.body}")
    expect(new_session.response.code).to eq 201
    expect(new_session.token.length).to be 64
    test_rail_result(1, "new session response code: #{new_session.response.code}")
    test_rail_result(1, "new session token: #{new_session.token}")
    test_rail_result(1, "new session token length: #{new_session.token.length}", "pass")

  end
end
