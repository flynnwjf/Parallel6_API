require_relative '../../../../../../../src/spec_helper'

describe 'Delete V3/mobile_users/:mobile_user_id/badges/:id/destroy' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
#Badge information
  let(:badge_create_testname) { "badges_create" }
  let(:badge_test_data) { DataHandler.get_test_data(badge_create_testname) }
  let(:badge_type) { badge_test_data["type"] }
  let(:badge_title) { badge_test_data["title"] }
  let(:badge_description) { badge_test_data["description"] }
#MobileUser Badge information
  let(:pre_testname) { "mobileuser_badges_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:mobile_user_id) { pre_test_data["mobile_user_id"] }
#Test Info
  let(:testname) { "mobileuser_badges_destroy" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobileuser_badges_destroy) { V3::MobileUser::Badges::Destroy.new(token, user_email, base_url, mobile_user_id, id)}

  context 'with valid user' do
    let(:badge_id) {V3::Badges::Create.new(token, user_email, base_url, badge_type, badge_title, badge_description).id}
    let(:id) { V3::MobileUser::Badges::Create.new(token, user_email, base_url, type, mobile_user_id, badge_id).id }
    it 'returns 204 status code' do
      expect(mobileuser_badges_destroy.response.code).to eq 204
      #cleanup
      expect(V3::Badges::Delete.new(token, user_email, base_url, badge_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(mobileuser_badges_destroy.response.code).to eq 404
      expect(mobileuser_badges_destroy.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:id) { "1" }
    it 'returns 403 or 404 error' do
      expect([403, 404]).to include (mobileuser_badges_destroy.response.code)
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:id) { "1" }
    it 'returns 401 error' do
      expect(mobileuser_badges_destroy.response.code).to eq 401
      expect(mobileuser_badges_destroy.response.body).to match /Authentication Failed/
    end
  end

end



