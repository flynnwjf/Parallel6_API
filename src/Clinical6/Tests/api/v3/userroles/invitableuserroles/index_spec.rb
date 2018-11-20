require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/user_roles/:id/invitable_user_roles' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "userroles_invitableuserroles_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:invitable_user_roles) { V3::UserRoles::InvitableUserRoles::Index.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:id) { test_data["id"] }
    it 'shows invitable user roles for the user role' do
      expect(invitable_user_roles.response.code).to eq 200
      expect(JSON.parse(invitable_user_roles.response.body).dig("data", 0, "type")).to eq "user_roles"
    end
  end

  context 'with invalid user' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error with record not found error' do
      expect(invitable_user_roles.response.code).to eq 404
      expect(invitable_user_roles.response.body).to match /Record Not Found/
    end
  end

end

