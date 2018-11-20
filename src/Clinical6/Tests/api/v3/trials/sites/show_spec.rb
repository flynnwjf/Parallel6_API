require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/trials/sites/:id/show' do
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
  let(:type) { pre_test_data["type"] }
  let(:name) { pre_test_data["name"] + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Test Info
  let(:testname) { "trials_sites_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:trials_sites_show) { V3::Trials::Sites::Show.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:id) {  V3::Trials::Sites::Create.new(token, user_email, base_url, type, name).id }
    it 'returns 200 status code' do
      expect(trials_sites_show.response.code).to eq 200
      expect(JSON.parse(trials_sites_show.response).dig('data', 'id')).to eq id
      #cleanup
      expect(V3::Trials::Sites::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(trials_sites_show.response.code).to eq 404
      expect(trials_sites_show.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:unauthorized_user_token) { V3::Users::Session::Create.new(unauthorized_email, unauthorized_password, base_url).token }
    let(:id) {  V3::Trials::Sites::Create.new(token, user_email, base_url, type, name).id }
    let(:trials_sites_show) { V3::Trials::Sites::Show.new(unauthorized_user_token, unauthorized_email, base_url, id) }
    it 'returns 403 error' do
      expect(trials_sites_show.response.code).to eq 403
      #cleanup
      expect(V3::Trials::Sites::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:trials_sites_show) { V3::Trials::Sites::Show.new(token, invalid_user, base_url, "1") }
    it 'returns 401 error' do
      expect(trials_sites_show.response.code).to eq 401
      expect(trials_sites_show.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



