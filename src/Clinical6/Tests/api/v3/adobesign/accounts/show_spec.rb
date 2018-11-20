require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/adobe_sign/accounts' do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "adobesign_accounts_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:adobesign_accounts_show) { V3::AdobeSign::Accounts::Show.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code & shows adobe sign account' do
      expect(adobesign_accounts_show.response.code).to eq 200
      #commenting this out as we cannot gurantee an account exists, and we arent supposed to create new accounts atm
      #expect(JSON.parse(adobesign_accounts_show.response).dig('data', 0, 'id')).not_to eq nil
      #expect(JSON.parse(adobesign_accounts_show.response).dig('data', 0, 'type')).to eq "adobe_sign__accounts"
    end
  end

  context 'with invalid user' do
     let(:user_email) { test_data["invalid_email"] }

     it 'returns 401 error when user email is not in the system' do
      expect(adobesign_accounts_show.response.code).to eq 401
      expect(adobesign_accounts_show.response.body).to match /Authentication Failed/
     end

  end

end



