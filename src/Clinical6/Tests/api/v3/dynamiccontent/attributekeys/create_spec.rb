require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/dynamiccontent/attributekeys/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "dynamiccontent_attributekeys_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:name) { test_data["name"] + DateTime.now.strftime('_%Q').to_s }
  let(:display_name) { test_data["display_name"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:attribute_keys_create) { V3::DynamicContent::AttributeKeys::Create.new(token, user_email, base_url, type, name, display_name) }
  let(:created_id) { attribute_keys_create.id }

  context 'with valid user and valid name' do
    it 'returns 201 status code & creates an attribute key' do
      expect(attribute_keys_create.response.code).to eq 201
      expect(created_id.to_i).to be >=1
      expect(JSON.parse(attribute_keys_create.response).dig('data','type')).to eq type
      expect(JSON.parse(attribute_keys_create.response).dig('data','attributes','name')).to eq name
      expect(JSON.parse(attribute_keys_create.response).dig('data','attributes','display_name')).to eq display_name
      puts "create_response_body: "+ attribute_keys_create.response.to_s
      #cleanup
      expect(V3::DynamicContent::AttributeKeys::Destroy.new(token, user_email, base_url, created_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid name' do
    let(:name) { test_data["invalid_key_name"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(attribute_keys_create.response.code).to eq 422
      expect(attribute_keys_create.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:attribute_keys_create) { V3::DynamicContent::AttributeKeys::Create.new(token, invalid_user, base_url, type, name, display_name) }
    it 'returns 401 error' do
      expect(attribute_keys_create.response.code).to eq 401
      expect(attribute_keys_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



