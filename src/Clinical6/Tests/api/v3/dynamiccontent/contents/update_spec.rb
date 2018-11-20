require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/dynamiccontent/contents/:id/update' do
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
  let(:pre_type) { pre_test_data["type"] }
  let(:content_type_id) { pre_test_data["content_type_id"] }
#Test Info
  let(:testname) { "dynamiccontent_contents_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] }
  let(:visibility_status) { test_data["visibility_status"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:contents_create) { V3::DynamicContent::Contents::Create.new(token, user_email, base_url, pre_type, content_type_id) }
  let(:updated_id) { contents_create.id }
  let(:contents_update) { V3::DynamicContent::Contents::Update.new(token, user_email, base_url, updated_id, type, title, visibility_status) }

  context 'with valid user and valid content id' do
    let(:contents_show) { V3::DynamicContent::Contents::Show.new(token, user_email, base_url, updated_id)}
    it 'returns 204 status code & updates a content' do
      expect(contents_create.response.code).to eq 201
      expect(contents_update.response.code).to eq 204
      expect(contents_show.response.code).to eq 200
      expect(JSON.parse(contents_show.response).dig('data', 'id')).to eq updated_id
      expect(JSON.parse(contents_show.response).dig('data','type')).to eq type
      expect(JSON.parse(contents_show.response).dig('data','attributes','title')).to eq title
      expect(JSON.parse(contents_show.response).dig('data','attributes','visibility_status')).to eq visibility_status
      #cleanup
      expect(V3::DynamicContent::Contents::Destroy.new(token, user_email, base_url, updated_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid visibility_status' do
    let(:visibility_status) { test_data["invalid_visibility_status"] }
    it 'returns 422 error & is not included in the list message in body' do
      expect(contents_create.response.code).to eq 201
      expect(contents_update.response.code).to eq 422
      expect(contents_update.response.body).to match /is not included in the list/
      #cleanup
      expect(V3::DynamicContent::Contents::Destroy.new(token, user_email, base_url, updated_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid content id' do
    let(:updated_id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(contents_create.response.code).to eq 201
      expect(contents_update.response.code).to eq 404
      expect(contents_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::DynamicContent::Contents::Destroy.new(token, user_email, base_url, contents_create.id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:contents_update) { V3::DynamicContent::Contents::Update.new(token, invalid_user, base_url, updated_id, type, title, visibility_status) }
    it 'returns 401 error' do
      expect(contents_create.response.code).to eq 201
      expect(contents_update.response.code).to eq 401
      expect(contents_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::DynamicContent::Contents::Destroy.new(token, user_email, base_url, updated_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



