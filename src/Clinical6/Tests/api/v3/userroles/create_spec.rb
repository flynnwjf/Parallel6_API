require_relative '../../../../../../src/spec_helper'

describe 'Post V3/user_roles' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "user_roles_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:link) { "Test_" + Time.new.strftime("%Y-%m-%d-%H-%M-%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:user_roles_create) { V3::UserRoles::Create.new(token, user_email, base_url, name, link) }

  context 'with valid user' do
      it 'returns 200 and creates new user role' do
        expect(user_roles_create.response.code).to eq 201
        expect(JSON.parse(user_roles_create.response).dig('data', 'type')).to eq "user_roles"
        expect(JSON.parse(user_roles_create.response).dig('data', 'attributes', 'name')).to eq name
      end
  end

  context 'with invalid name' do
    let(:name) { test_data["invalid_name"] }
    it 'returns 422 error & record not found message' do
      expect(user_roles_create.response.code).to eq 422
      expect(user_roles_create.response.body).to match /can't be blank/
    end
  end

end

