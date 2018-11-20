require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/mobile_users/session' do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }

  #Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:device_id) { env_user["device_id"] }

  #Test Info
  let(:testname) { "mobileuser_sessions_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  #Requests
  let(:session) { V3::MobileUser::Session::Create.new(user_email, user_password, base_url, device_id) }

  context 'with valid user' do
    it 'grants access token that is 128 bith encrypted' do
      expect(session.response.code).to eq 200
      expect(session.token.length).to be 64
    end
    it 'contains has valid fields (email, user level)' do
      expect(session.email).to match user_email
      expect(JSON.parse(session.response.body).dig("data", "type")).to eq "mobile_users"
    end
  end


  context 'with invalid user' do
    let(:user_email) { test_data["invalid_email"] }
    it 'returns 401 error and cred review message' do
      expect(session.response.code).to eq 401
      expect(session.response.body).to match /Please review your credentials/
    end
  end

  context 'with invalid password' do
    let(:user_password) { test_data["invalid_password"] }
    it 'returns 401 error and Unauthorizd in body' do
      expect(session.response.code).to eq 401
      expect(session.response.body).to match /Unauthorized/
    end
  end

end



