require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/adobe_sign/oauth_authorize' do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "adobesign_oauth_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:adobesign_oauth_show) { V3::AdobeSign::Oauth::Show.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code & shows adobe sign account oauth' do
      expect(adobesign_oauth_show.response.code).to eq 200
      expect(JSON.parse(adobesign_oauth_show.response).dig('redirect_url')).to match "success_url"
    end
  end

  context 'with invalid user' do
     let(:user_email) { test_data["invalid_email"] }
     it 'returns 401 error' do
      expect(adobesign_oauth_show.response.code).to eq 401
    end
  end

end



