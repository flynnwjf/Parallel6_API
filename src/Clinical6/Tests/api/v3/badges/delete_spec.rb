require_relative '../../../../../../src/spec_helper'

describe 'Delete V3/badges/:id/delete' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "badges_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:title) { pre_test_data["title"] }
  let(:description) { pre_test_data["description"] }
#Test Info
  let(:testname) { "badges_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:badges_create) { V3::Badges::Create.new(token, user_email, base_url, type, title, description) }
  let(:id) { badges_create.id }
  let(:badges_delete) { V3::Badges::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 204 status code & deletes a badge' do
      expect(badges_create.response.code).to eq 201
      expect(badges_delete.response.code).to eq 204
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid badge id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(badges_delete.response.code).to eq 404
      expect(badges_delete.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:badges_delete) { V3::Badges::Delete.new(token, invalid_user, base_url, id) }
    it 'returns 401 error' do
      expect(badges_delete.response.code).to eq 401
      expect(badges_delete.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



