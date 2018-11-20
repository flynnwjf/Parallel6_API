require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/users/session/create' do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "user_sessions_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:session) { V3::Users::Session::Create.new(user_email, user_password, base_url) }

  context 'with valid user' do
    it 'grants session token that is 128 bith encrypted' do
      expect(session.response.code).to eq 201
      expect(session.token.length).to be 64
    end
    it 'contains has valid fields (email, user level)' do
      expect(session.email).to match user_email
      expect(JSON.parse(session.response).dig('included', 1, 'attributes', 'is_super')).to be true
    end
  end


  context 'with invalid user' do
    let(:user_email) { "9129310231" }
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

=begin
  context 'with locked account' do
    let(:user_email) { test_data["locked_user_name"] }
    let(:user_password) { test_data["invalid_password"] }
    it 'returns 401 error and verifies locked account' do
      #loop 5 times to make sure account gets locked
      for i in 1..5 do
        session = V3::Users::Session::Create.new(user_email, user_password, base_url)
        puts session.response.body
      end
      expect(session.response.code).to eq 401
      expect(session.response.body).to match /Your account is locked/
    end
  end
=end
end



