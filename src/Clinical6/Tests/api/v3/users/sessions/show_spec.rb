require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/users/session/show' do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "user_sessions_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:session) { V3::Users::Session::Show.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 code & shows token for the user' do
      expect(session.response.code).to eq 200
      expect(session.token_show).to eq token
    end
  end

  context 'with invalid user' do
    let(:user_email) { test_data["invalid_name"] }
    it 'returns 401 error & authentication failed message' do
      expect(session.response.code).to eq 401
      expect(session.response.body).to match /Authentication Failed/
    end
  end

end

