require_relative '../../../../../../src/spec_helper'

describe 'Delete V3/mobile_users/:id/destroy' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Unauthorized User
  let(:env_unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_email) { env_unauthorized_user["email"] }
  let(:unauthorized_password) { env_unauthorized_user["password"] }
#Preconditions
  let(:pre_testname) { "mobile_user_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:mobile_user_email) { pre_test_data["mobile_user_email"] + DateTime.now.strftime("+%Q") + "@mailinator.com" }
  let(:user_role_id) { pre_test_data["user_role_id"] }
#Test Info
  let(:testname) { "mobile_user_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobile_user_delete) { V3::MobileUser::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:mobile_user_create) { V3::MobileUser::Create.new(token, user_email, base_url, type, mobile_user_email, user_role_id) }
    let(:id) { mobile_user_create.id}
    it 'returns 204 status code' do
      expect(mobile_user_create.response.code).to eq 201
      expect(mobile_user_delete.response.code).to eq 204
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(mobile_user_delete.response.code).to eq 404
      expect(mobile_user_delete.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:unauthorized_user_token) { V3::Users::Session::Create.new(unauthorized_email, unauthorized_password, base_url).token }
    let(:id) {  V3::MobileUser::Create.new(token, user_email, base_url, type, mobile_user_email, user_role_id).id }
    let(:mobile_user_delete) { V3::MobileUser::Delete.new(unauthorized_user_token, unauthorized_email, base_url, id) }
    it 'returns 403 error' do
      expect(mobile_user_delete.response.code).to eq 403
      #cleanup
      expect(V3::MobileUser::Delete.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:mobile_user_delete) { V3::MobileUser::Delete.new(token, invalid_user, base_url, "1") }
    it 'returns 401 error' do
      expect(mobile_user_delete.response.code).to eq 401
      expect(mobile_user_delete.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



