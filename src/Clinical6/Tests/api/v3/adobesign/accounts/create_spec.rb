require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/adobesign/accounts/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "adobesign_accounts_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:adobe_email) { test_data["adobe_email"] + DateTime.now.strftime('+%Q').to_s + "@mailinator.com"}
 #Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:adobesign_accounts_create) { V3::AdobeSign::Accounts::Create.new(token, user_email, base_url, type, adobe_email) }
  let(:created_id) { adobesign_accounts_create.id}

  #Skipping because we don't want to create actual users on adobe system for now.
  # TODO: mock this?
  context 'with valid user' do
    let(:adobesign_accounts_show) { V3::AdobeSign::Accounts::Show.new(token, user_email, base_url) }
    xit 'returns 201 status code ' do
      if (adobesign_accounts_show.response.body.size > 100)
        id =JSON.parse(adobesign_accounts_show.response).dig('data', 0, 'id')
        expect(V3::AdobeSign::Accounts::Delete.new(token,user_email,base_url,id).response.code).to eq 204
      end
      expect(adobesign_accounts_create.response.code).to eq 201
      expect(JSON.parse(adobesign_accounts_create.response).dig('data','type')).to eq type
      expect(JSON.parse(adobesign_accounts_create.response).dig('data', 'attributes','email')).to eq adobe_email
      #cleanup
      expect(V3::AdobeSign::Accounts::Delete.new(token,user_email,base_url,created_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:adobe_email) { test_data["invalid_parameter"] }
    it 'returns 422 error' do
      expect(adobesign_accounts_create.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  # context 'with unauthorized user' do
  #   let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  #   let(:user_email) { env_user["email"] }
  #   let(:user_password) { env_user["password"] }
  #   it 'returns 403 error' do
  #     expect(adobesign_accounts_create.response.code).to eq 403
  #     #cleanup
  #     expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
  #   end
  # end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:adobesign_accounts_create) { V3::AdobeSign::Accounts::Create.new(token, invalid_user, base_url, type, adobe_email) }
    it 'returns 401 error' do
      expect(adobesign_accounts_create.response.code).to eq 401
      expect(adobesign_accounts_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



