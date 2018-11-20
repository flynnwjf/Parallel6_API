require_relative '../../../../../../src/spec_helper'

describe 'Patch V3/user_roles/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "user_roles_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Update Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:link) { "Update_Test_" + Time.new.strftime("%Y-%m-%d-%H-%M-%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::UserRoles::Index.new(token, user_email, base_url).user_role_id }
  let(:user_roles_update) { V3::UserRoles::Update.new(token, user_email, base_url, id, name, link) }

  context 'with valid user' do
    it 'returns 200 code and update video consultation' do
      expect(user_roles_update.response.code).to eq 200
      expect(JSON.parse(user_roles_update.response.body).dig("data", "id")).to eq id
      expect(JSON.parse(user_roles_update.response.body).dig("data", "attributes", "name")).to eq name
    end
  end

  context 'with invalid parameter' do
    let(:name) {test_data["invalid_name"]}
    it 'returns 422 error & cannot be blank message in body' do
      expect(user_roles_update.response.code).to eq 422
      expect(user_roles_update.response.body).to match /can't be blank/
    end
  end

end

