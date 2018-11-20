require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/users/invitation/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "users_invitation_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:invite_email) { test_data["email"] + DateTime.now.strftime('+%Q').to_s + "@mailinator.com"}
  let(:user_role_id) { test_data["user_role_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:users_invitation_create) { V3::Users::Invitation::Create.new(token, user_email, base_url, type, invite_email, user_role_id) }

  context 'with valid user' do
    it 'returns 200 status code & sends an email invitation' do
      expect(users_invitation_create.response.code).to eq 200
      expect(JSON.parse(users_invitation_create.response).dig('data','type')).to eq "users"
      expect(JSON.parse(users_invitation_create.response).dig('data', 'attributes','email')).to eq invite_email
      expect(JSON.parse(users_invitation_create.response).dig('data', 'relationships','user_role', 'data', 'id')).to eq user_role_id
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 403 error' do
      expect(users_invitation_create.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end


  context 'with invalid parameter' do
    let(:invite_email) { test_data["invalid_email"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(users_invitation_create.response.code).to eq 422
      expect(users_invitation_create.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:users_invitation_create) { V3::Users::Invitation::Create.new(token, invalid_user, base_url, type, invite_email, user_role_id) }
    it 'returns 401 error' do
      expect(users_invitation_create.response.code).to eq 401
      expect(users_invitation_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



