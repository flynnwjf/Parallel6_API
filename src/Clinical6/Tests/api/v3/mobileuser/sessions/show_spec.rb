require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/mobile_users/sessions' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:device_id) { env_user["device_id"]}
#Test Info
  let(:testname) { "mobileuser_sessions_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::MobileUser::Session::Create.new(user_email, user_password, base_url, device_id).token }
  let(:mobileuser_sessions_show) { V3::MobileUser::Session::Show.new(base_url, token) }

  context 'with valid user' do
    it 'returns 200 and shows session of mobile user' do
      expect(mobileuser_sessions_show.response.code).to eq 200
      expect(JSON.parse(mobileuser_sessions_show.response.body).dig("data", "id")).not_to eq nil
      expect(JSON.parse(mobileuser_sessions_show.response.body).dig("data", "type")).to eq "mobile_users"
    end
  end

  context 'with invalid token' do
    let(:token) { test_data["invalid_token"] }
    it 'returns 401 error and Authentication Failed in body' do
      expect(mobileuser_sessions_show.response.code).to eq 401
      expect(mobileuser_sessions_show.response.body).to match /Authentication Failed/
    end
  end

end

