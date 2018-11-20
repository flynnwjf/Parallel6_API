require_relative '../../../../../../../src/spec_helper'

describe 'PATCH V3/trials/sites/:id/update' do
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
  let(:pre_testname) { "trials_sites_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:pre_type) { pre_test_data["type"] }
  let(:pre_name) { pre_test_data["name"] + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Test Info
  let(:testname) { "trials_sites_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:name) { test_data["name"] + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:trials_sites_update) { V3::Trials::Sites::Update.new(token, user_email, base_url, type, name, id) }

  context 'with valid user' do
    let(:id) {  V3::Trials::Sites::Create.new(token, user_email, base_url, pre_type, pre_name).id }
    it 'returns 200 status code' do
      expect(trials_sites_update.response.code).to eq 200
      expect(JSON.parse(trials_sites_update.response).dig('data', 'id')).to eq id
      expect(JSON.parse(trials_sites_update.response).dig('data', 'attributes', 'name')).to eq name
      #cleanup
      expect(V3::Trials::Sites::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(trials_sites_update.response.code).to eq 404
      expect(trials_sites_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:name) { test_data["invalid_parameter"] }
    let(:id) { "1" }
    it 'returns 422 error' do
      expect(trials_sites_update.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:unauthorized_user_token) { V3::Users::Session::Create.new(unauthorized_email, unauthorized_password, base_url).token }
    let(:id) {  V3::Trials::Sites::Create.new(token, user_email, base_url, pre_type, pre_name).id }
    let(:trials_sites_update) { V3::Trials::Sites::Update.new(unauthorized_user_token, unauthorized_email, base_url,type, name, id) }
    it 'returns 403 error' do
      expect(trials_sites_update.response.code).to eq 403
      #cleanup
      expect(V3::Trials::Sites::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:trials_sites_update) { V3::Trials::Sites::Update.new(token, invalid_user, base_url,type, name, "1") }
    it 'returns 401 error' do
      expect(trials_sites_update.response.code).to eq 401
      expect(trials_sites_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



