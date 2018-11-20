require_relative '../../../../../../src/spec_helper'

describe 'Patch V3/permissions/:id/update' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "permissions_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:pre_type) { pre_test_data["type"] }
  let(:pre_scope_name) { pre_test_data["scope_name"] }
  let(:pre_authorizable_id) { pre_test_data["authorizable_id"] }
#Test Info
  let(:testname) { "permissions_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:scope_name) { test_data["scope_name"] }
  let(:authorizable_id) { test_data["authorizable_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:permissions_create) { V3::Permissions::Create.new(token, user_email, base_url, pre_type, pre_scope_name, pre_authorizable_id) }
  let(:id) { permissions_create.id }
  let(:permissions_update) { V3::Permissions::Update.new(token, user_email, base_url, id, type, scope_name, authorizable_id) }

  context 'with valid user and valid parameters' do
    it 'returns 200 status code' do
      expect(permissions_create.response.code).to eq 201
      expect(permissions_update.response.code).to eq 200
      expect(JSON.parse(permissions_update.response).dig('data','id')).to eq id
      expect(JSON.parse(permissions_update.response).dig('data','type')).to eq type
      expect(JSON.parse(permissions_update.response).dig('data', 'attributes',"scope_name")).to eq scope_name
      expect(JSON.parse(permissions_update.response).dig('data','relationships','authorizable','data','id')).to eq authorizable_id
      puts "permissions_update_response_body: " + permissions_update.response.body.to_s
      #cleanup
      expect(V3::Permissions::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid parameters' do
    let(:authorizable_id) { test_data["invalid_authorizable_id"] }
    it 'returns 422 error & Invalid parameters message in body' do
      expect(permissions_create.response.code).to eq 201
      expect(permissions_update.response.code).to eq 422
      expect(permissions_update.response.body).to match /Invalid parameters/
      #cleanup
      expect(V3::Permissions::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:permissions_update) { V3::Permissions::Update.new(token, invalid_user, base_url, id, type, scope_name, authorizable_id) }
    it 'returns 401 error' do
      expect(permissions_create.response.code).to eq 201
      expect(permissions_update.response.code).to eq 401
      expect(permissions_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Permissions::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(permissions_create.response.code).to eq 201
      expect(permissions_update.response.code).to eq 404
      expect(permissions_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Permissions::Destroy.new(token, user_email, base_url, permissions_create.id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



