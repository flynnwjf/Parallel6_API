require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/trials/site_members/:id/update' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:mobileuser_testname) { "mobile_user_create" }
  let(:mobileuser_test_data) { DataHandler.get_test_data(mobileuser_testname) }
  let(:mobile_user_type) { mobileuser_test_data["type"] }
  let(:mobile_user_email) { mobileuser_test_data["mobile_user_email"] + DateTime.now.strftime("+%Q") + "@mailinator.com" }
  let(:user_role_id) { mobileuser_test_data["user_role_id"] }
  let(:sitemember_testname) { "trials_sitemember_create" }
  let(:sitemember_test_data) { DataHandler.get_test_data(sitemember_testname) }
  let(:sitemember_type) { sitemember_test_data["type"] }
#Test Info
  let(:testname) { "trials_sitemember_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:trials_sitemember_update) { V3::Trials::SiteMember::Update.new(token, user_email, base_url, type, update_mobile_user_id, id) }

  context 'with valid user' do
    let(:mobile_user_id) { V3::MobileUser::Create.new(token, user_email, base_url, mobile_user_type, mobile_user_email, user_role_id).id}
    let(:id) { V3::Trials::SiteMember::Create.new(token, user_email, base_url, sitemember_type, mobile_user_id).id }
    let(:update_mobile_user_email) { "mobile_update"+ DateTime.now.strftime("+%Q") + "@mailinator.com"}
    let(:update_mobile_user_id) { V3::MobileUser::Create.new(token, user_email, base_url, mobile_user_type, update_mobile_user_email, user_role_id).id}
    it 'returns 200 status code' do
      expect(trials_sitemember_update.response.code).to eq 200
      expect(JSON.parse(trials_sitemember_update.response).dig('data', 'id')).to eq id
      expect(JSON.parse(trials_sitemember_update.response).dig('data', 'relationships', 'mobile_user', 'data', 'id')).to eq update_mobile_user_id
      #cleanup
      expect(V3::Trials::SiteMember::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::MobileUser::Delete.new(token, user_email, base_url, update_mobile_user_id).response.code).to eq 204
      expect(V3::MobileUser::Delete.new(token, user_email, base_url, mobile_user_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:update_mobile_user_id) { "1" }
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(trials_sitemember_update.response.code).to eq 404
      expect(trials_sitemember_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:update_mobile_user_id) { test_data["invalid_parameter"] }
    let(:id) { "1" }
    it 'returns 422 error' do
      expect(trials_sitemember_update.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:trials_sitemember_update) { V3::Trials::SiteMember::Update.new(token, user_email, base_url,type, "1", "1") }
    it 'returns 403 error' do
      expect(trials_sitemember_update.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:trials_sitemember_update) { V3::Trials::SiteMember::Update.new(token, invalid_user, base_url,type, "1", "1") }
    it 'returns 401 error' do
      expect(trials_sitemember_update.response.code).to eq 401
      expect(trials_sitemember_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



