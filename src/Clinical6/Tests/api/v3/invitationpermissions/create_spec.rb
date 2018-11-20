require_relative '../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/invitation_permissions/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "invitation_permissions_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:invitation_permissions_create) { V3::InvitationPermissions::Create.new(token, user_email, base_url, type, user_role_id) }

  context 'with valid user' do
    let(:user_roles_create) { V3::UserRoles::Create.new(token, user_email, base_url, "Test "+Time.new.strftime("%Y-%m-%d %H:%M:%S"), "Test_"+Time.new.strftime("%Y-%m-%d-%H-%M-%S")) }
    let(:user_role_id) { user_roles_create.user_role_id }
    it 'creates a user role before' do
      expect(user_roles_create.response.code).to eq 201
    end
    it 'returns 201 status code ' do
      expect(invitation_permissions_create.response.code).to eq 201
      expect(JSON.parse(invitation_permissions_create.response).dig('data','type')).to eq type
      expect(JSON.parse(invitation_permissions_create.response).dig('data', 'relationships','inviter_user_role', 'data', 'id')).to eq user_role_id
      #cleanup
      #Pendng user role and invitation permission delete implementation
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:user_role_id) { test_data["invalid_parameter"] }
    it 'returns 422 error' do
      expect(invitation_permissions_create.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:user_role_id) { "1" }
    it 'returns 403 error' do
      expect(invitation_permissions_create.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:invitation_permissions_create) { V3::InvitationPermissions::Create.new(token, invalid_user, base_url, type, "1") }
    it 'returns 401 error' do
      expect(invitation_permissions_create.response.code).to eq 401
      expect(invitation_permissions_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



