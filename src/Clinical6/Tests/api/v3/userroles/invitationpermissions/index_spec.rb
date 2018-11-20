require_relative '../../../../../../../src/spec_helper'

describe 'GET V3/user_roles/:id/invitation_permissions/index' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "userroles_invitationpermissions_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:userroles_invitationpermissions_index) { V3::UserRoles::InvitationPermissions::Index.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:id) { test_data["id"] }
    it 'returns 200 status code' do
      expect(userroles_invitationpermissions_index.response.code).to eq 200
      expect(JSON.parse(userroles_invitationpermissions_index.response.body).dig("data", 0, "type")).to eq "invitation_permissions"
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & shows Record Not Found in response body' do
      expect(userroles_invitationpermissions_index.response.code).to eq 404
      expect(userroles_invitationpermissions_index.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:id) { test_data["id"] }
    it 'returns 403 error' do
      expect(userroles_invitationpermissions_index.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:id) { test_data["id"] }
    let(:userroles_invitationpermissions_index) { V3::UserRoles::InvitationPermissions::Index.new(token, invalid_user, base_url, id) }
    it 'returns 401 error' do
      expect(userroles_invitationpermissions_index.response.code).to eq 401
      expect(userroles_invitationpermissions_index.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end



end

