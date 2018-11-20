require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/dynamiccontent/contents/index' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "dynamiccontent_contents_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:content_type_id) { pre_test_data["content_type_id"] }
#Test Info
  let(:testname) { "dynamiccontent_contents_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:contents_create) { V3::DynamicContent::Contents::Create.new(token, user_email, base_url, type, content_type_id) }
  let(:contents_index) { V3::DynamicContent::Contents::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code' do
      expect(contents_create.response.code).to eq 201
      expect(contents_index.response.code).to eq 200
      #cleanup
      expect(V3::DynamicContent::Contents::Destroy.new(token, user_email, base_url, contents_create.id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

   context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:contents_index) { V3::DynamicContent::Contents::Index.new(token, invalid_user, base_url) }
    it 'returns 401 error' do
      expect(contents_create.response.code).to eq 201
      expect(contents_index.response.code).to eq 401
      expect(contents_index.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::DynamicContent::Contents::Destroy.new(token, user_email, base_url, contents_create.id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



