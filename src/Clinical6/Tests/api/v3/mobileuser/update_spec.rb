require_relative '../../../../../../src/spec_helper'

describe 'Patch V3/mobile_users/:id/update' do

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
  let(:pre_type) { pre_test_data["type"] }
  let(:pre_mobile_user_email) { pre_test_data["mobile_user_email"] + DateTime.now.strftime("+%Q") + "@mailinator.com" }
  let(:user_role_id) { pre_test_data["user_role_id"] }
#Test Info
  let(:testname) { "mobile_user_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:mobile_user_email) { test_data["mobile_user_email"] + DateTime.now.strftime("+%Q") + "@mailinator.com" }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobile_user_update) { V3::MobileUser::Update.new(token, user_email, base_url, type, mobile_user_email, id) }

  context 'with valid user' do
    let(:id) {  V3::MobileUser::Create.new(token, user_email, base_url, pre_type, pre_mobile_user_email, user_role_id).id }
    it 'returns 200 status code' do
      expect(mobile_user_update.response.code).to eq 200
      expect(JSON.parse(mobile_user_update.response).dig('data', 'id')).to eq id
      expect(JSON.parse(mobile_user_update.response).dig('data', 'attributes', 'email')).to eq mobile_user_email
      #cleanup
      expect(V3::MobileUser::Delete.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(mobile_user_update.response.code).to eq 404
      expect(mobile_user_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:unauthorized_user_token) { V3::Users::Session::Create.new(unauthorized_email, unauthorized_password, base_url).token }
    let(:id) {  V3::MobileUser::Create.new(token, user_email, base_url, pre_type, pre_mobile_user_email, user_role_id).id }
    let(:mobile_user_update) { V3::MobileUser::Update.new(unauthorized_user_token, unauthorized_email, base_url,type, mobile_user_email, id) }
    it 'returns 403 error' do
      expect(mobile_user_update.response.code).to eq 403
      #cleanup
      expect(V3::MobileUser::Delete.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:mobile_user_update) { V3::MobileUser::Update.new(token, invalid_user, base_url,type, mobile_user_email, "1") }
    it 'returns 401 error' do
      expect(mobile_user_update.response.code).to eq 401
      expect(mobile_user_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



