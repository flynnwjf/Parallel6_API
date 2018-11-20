require_relative '../../../../../../src/spec_helper'

describe 'Post V3/allowed_actions' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "allowed_actions_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:allowed_actions_create) { V3::AllowedAction::Create.new(token, user_email, base_url, name) }
  let(:allowed_actions_delete) { V3::AllowedAction::Delete.new(token, user_email, base_url, allowed_actions_create.id) }

  context 'with valid user' do
    it 'returns 200 status code & create allowed action' do
      expect(allowed_actions_create.response.code).to eq 200
      expect(JSON.parse(allowed_actions_create.response.body).dig("data", "type")).to eq "allowed_actions"
      expect(JSON.parse(allowed_actions_create.response.body).dig("data", "attributes", "name")).to eq name
      #Clean Up
      expect(allowed_actions_delete.response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:name) { test_data["invalid_name"] }
    it 'returns 422 error' do
      expect(allowed_actions_create.response.code).to eq 422
      expect(allowed_actions_create.response.body).to match /can't be blank/
    end
  end

end



