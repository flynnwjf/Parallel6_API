require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/mobile_users/:id/consent/grants' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "mobileuser_consent_grant_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobileuser_consent_grant_index) { V3::MobileUser::Consent::Grant::Index.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:id) { test_data["id"] }
    it 'returns 200 and shows the consent grant of mobile user' do
      expect(mobileuser_consent_grant_index.response.code).to eq 200
      expect(JSON.parse(mobileuser_consent_grant_index.response).dig('data', 0, 'type')).to eq "consent__grants"
      expect(JSON.parse(mobileuser_consent_grant_index.response).dig('data', 0, 'attributes', 'document', 'url')).not_to eq "null"
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error and Record Not Found in body' do
      expect(mobileuser_consent_grant_index.response.code).to eq 404
      expect(mobileuser_consent_grant_index.response.body).to match /Record Not Found/
    end
  end

end

