require_relative '../../../../../../src/spec_helper'

describe 'Post V3/permissions/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "permissions_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:scope_name) { test_data["scope_name"] }
  let(:authorizable_id) { test_data["authorizable_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:permissions_create) { V3::Permissions::Create.new(token, user_email, base_url, type, scope_name, authorizable_id) }
  let(:created_id) { permissions_create.id }

  context 'with valid user and valid parameters' do
    it 'returns 201 status code & creates a permission' do
      expect(permissions_create.response.code).to eq 201
      expect(created_id.to_i).to be >=1
      expect(JSON.parse(permissions_create.response).dig('data','type')).to eq type
      expect(JSON.parse(permissions_create.response).dig('data', 'attributes','scope_name')).to eq scope_name
      expect(JSON.parse(permissions_create.response).dig('data','relationships','authorizable','data','id')).to eq authorizable_id
      puts "permissions_create_response_body: " + permissions_create.response.body.to_s
      #cleanup
      expect(V3::Permissions::Destroy.new(token, user_email, base_url, created_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid parameters' do
    let(:authorizable_id) { test_data["invalid_authorizable_id"] }
    it 'returns 422 error & Invalid parameters message in body' do
      expect(permissions_create.response.code).to eq 422
      expect(permissions_create.response.body).to match /Invalid parameters/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:permissions_create) { V3::Permissions::Create.new(token, invalid_user, base_url, type, scope_name, authorizable_id) }
    it 'returns 401 error' do
      expect(permissions_create.response.code).to eq 401
      expect(permissions_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



