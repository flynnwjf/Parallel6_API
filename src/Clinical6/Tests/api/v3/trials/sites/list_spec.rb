require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/trials/sites/list' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "trials_sites_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:name) { pre_test_data["name"] + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Test Info
  let(:testname) { "trials_sites_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:trials_sites_list) { V3::Trials::Sites::List.new(token, user_email, base_url) }

  context 'with valid user' do
    let(:trials_sites_create) { V3::Trials::Sites::Create.new(token, user_email, base_url, type, name) }
    it 'returns 200 status code' do
      expect(trials_sites_create.response.code).to eq 201
      expect(trials_sites_list.response.code).to eq 200
      #cleanup
      expect(V3::Trials::Sites::Destroy.new(token, user_email,base_url, trials_sites_create.id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 403 error' do
      expect(trials_sites_list.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
     it 'returns 401 error' do
      expect(trials_sites_list.response.code).to eq 401
      expect(trials_sites_list.response.body).to match /Authentication Failed/
    end
  end

end



