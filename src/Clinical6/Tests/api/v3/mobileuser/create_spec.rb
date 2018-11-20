require_relative '../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/mobile_users/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "mobile_user_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:mobile_user_email) { test_data["mobile_user_email"] + DateTime.now.strftime("+%Q") + "@mailinator.com" }
  let(:user_role_id) { test_data["user_role_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobile_user_create) { V3::MobileUser::Create.new(token, user_email, base_url, type, mobile_user_email, user_role_id) }
  let(:mobile_user_id) { mobile_user_create.id}
  context 'with valid user' do
    it 'returns 201 status code ' do
      expect(mobile_user_create.response.code).to eq 201
      expect(JSON.parse(mobile_user_create.response).dig('data', 'type')).to eq type
      expect(JSON.parse(mobile_user_create.response).dig('data', 'attributes', 'email')).to eq mobile_user_email
      #cleanup
      expect(V3::MobileUser::Delete.new(token, user_email, base_url, mobile_user_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:user_role_id) { test_data["invalid_parameter"] }
    it 'returns 422 error' do
      expect(mobile_user_create.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 403 error' do
      expect(mobile_user_create.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:mobile_user_create) { V3::MobileUser::Create.new(token, invalid_user, base_url, type, mobile_user_email, user_role_id) }
    it 'returns 401 error' do
      expect(mobile_user_create.response.code).to eq 401
      expect(mobile_user_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



