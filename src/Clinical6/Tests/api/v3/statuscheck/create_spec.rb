require_relative '../../../../../../src/spec_helper'

describe 'Post V3/status_check' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "status_check_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:status_check_create) { V3::StatusCheck::Create.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 201 status code & creates a status' do
      expect(status_check_create.response.code).to eq 201
      expect(JSON.parse(status_check_create.response).dig('data','type')).to eq "statuses"
      expect(JSON.parse(status_check_create.response).dig('data', 'id')).not_to eq nil
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(status_check_create.response.code).to eq 401
      expect(status_check_create.response.body).to match /Authentication Failed/
    end
  end

end



