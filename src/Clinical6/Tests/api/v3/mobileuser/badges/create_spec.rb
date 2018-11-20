require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/mobile_users/:mobile_user_id/badges/create' do
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
  let(:pre_type) { pre_test_data["type"] }
  let(:title) { pre_test_data["title"] }
  let(:description) { pre_test_data["description"] }
#Test Info
  let(:testname) { "mobileuser_badges_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:mobile_user_id) { test_data["mobile_user_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobileuser_badges_create) { V3::MobileUser::Badges::Create.new(token, user_email, base_url, type, mobile_user_id, badge_id) }
  let(:created_id) { mobileuser_badges_create.id}

  context 'with valid user' do
    let(:badge_id) {V3::Badges::Create.new(token, user_email, base_url, pre_type, title, description).id}
    it 'returns 201 status code ' do
      expect(mobileuser_badges_create.response.code).to eq 201
      expect(JSON.parse(mobileuser_badges_create.response).dig('data', 'type')).to eq "awarded_badges"
      expect(JSON.parse(mobileuser_badges_create.response).dig('data', 'relationships', 'awardee', 'data', 'id')).to eq mobile_user_id
      expect(JSON.parse(mobileuser_badges_create.response).dig('data', 'relationships', 'badge', 'data', 'id')).to eq badge_id
      #cleanup
      expect(V3::MobileUser::Badges::Destroy.new(token, user_email, base_url, mobile_user_id, created_id).response.code).to eq 204
      expect(V3::Badges::Delete.new(token, user_email, base_url, badge_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:badge_id) { test_data["invalid_parameter"] }
    it 'returns 422 error' do
      expect(mobileuser_badges_create.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:badge_id) { "1" }
    it 'returns 403 or 404 error' do
      expect([403, 404]).to include (mobileuser_badges_create.response.code)
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:badge_id) { "1" }
    it 'returns 401 error' do
      expect(mobileuser_badges_create.response.code).to eq 401
      expect(mobileuser_badges_create.response.body).to match /Authentication Failed/
    end
  end

end



