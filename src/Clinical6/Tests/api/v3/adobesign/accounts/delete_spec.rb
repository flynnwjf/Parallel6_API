require_relative '../../../../../../../src/spec_helper'

describe 'Delete V3/adobe_sign/accounts/:id/delete' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "adobesign_accounts_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:adobe_email) { pre_test_data["adobe_email"] + DateTime.now.strftime('+%Q').to_s + "@mailinator.com" }
#Test Info
  let(:testname) { "adobesign_accounts_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:adobesign_accounts_delete) { V3::AdobeSign::Accounts::Delete.new(token, user_email, base_url, id) }

#  #Skipping because we don't want to create actual users on adobe system for now.
# TODO: mock this?
  context 'with valid user' do
    #let(:adobesign_accounts_create) { V3::AdobeSign::Accounts::Create.new(token, user_email, base_url, type, adobe_email) }
    #let(:id) { adobesign_accounts_create.id }
    xit 'returns 204 status code' do
      expect(adobesign_accounts_create.response.code).to eq 201
      expect(adobesign_accounts_delete.response.code).to eq 204
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(adobesign_accounts_delete.response.code).to eq 404
      expect(adobesign_accounts_delete.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:adobesign_accounts_delete) { V3::AdobeSign::Accounts::Delete.new(token, invalid_user, base_url, id) }
    let(:id) { "1" }
    it 'returns 401 error' do
      expect(adobesign_accounts_delete.response.code).to eq 401
      expect(adobesign_accounts_delete.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



