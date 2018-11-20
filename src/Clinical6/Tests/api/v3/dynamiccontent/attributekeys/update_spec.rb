require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/dynamiccontent/attributekeys/:id/update' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "dynamiccontent_attributekeys_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:pre_type) { pre_test_data["type"] }
  let(:pre_name) { pre_test_data["name"] + DateTime.now.strftime('_%Q').to_s }
  let(:pre_display_name) { pre_test_data["display_name"] }
#Test Info
  let(:testname) { "dynamiccontent_attributekeys_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:name) { test_data["name"] + DateTime.now.strftime('_%Q').to_s }
  let(:display_name) { test_data["display_name"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:attribute_keys_create) { V3::DynamicContent::AttributeKeys::Create.new(token, user_email, base_url, pre_type, pre_name, pre_display_name) }
  let(:updated_id) { attribute_keys_create.id }
  let(:attribute_keys_update) { V3::DynamicContent::AttributeKeys::Update.new(token, user_email, base_url, updated_id, type, name, display_name) }

  context 'with valid user and valid attribute key id' do
    it 'returns 200 status code & updates an attribute key' do
      expect(attribute_keys_create.response.code).to eq 201
      expect(attribute_keys_update.response.code).to eq 200
      expect(JSON.parse(attribute_keys_update.response).dig('data', 'id')).to eq updated_id
      expect(JSON.parse(attribute_keys_update.response).dig('data','type')).to eq type
      expect(JSON.parse(attribute_keys_update.response).dig('data','attributes','name')).to eq name
      expect(JSON.parse(attribute_keys_update.response).dig('data','attributes','display_name')).to eq display_name
      #cleanup
      expect(V3::DynamicContent::AttributeKeys::Destroy.new(token, user_email, base_url, updated_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid name' do
    let(:name) { test_data["invalid_key_name"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(attribute_keys_create.response.code).to eq 201
      expect(attribute_keys_update.response.code).to eq 422
      expect(attribute_keys_update.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::DynamicContent::AttributeKeys::Destroy.new(token, user_email, base_url, updated_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid attribute key id' do
    let(:updated_id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(attribute_keys_create.response.code).to eq 201
      expect(attribute_keys_update.response.code).to eq 404
      expect(attribute_keys_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::DynamicContent::AttributeKeys::Destroy.new(token, user_email, base_url, attribute_keys_create.id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:attribute_keys_update) { V3::DynamicContent::AttributeKeys::Update.new(token, invalid_user, base_url, updated_id, type, name, display_name) }
    it 'returns 401 error' do
      expect(attribute_keys_create.response.code).to eq 201
      expect(attribute_keys_update.response.code).to eq 401
      expect(attribute_keys_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::DynamicContent::AttributeKeys::Destroy.new(token, user_email, base_url, updated_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



