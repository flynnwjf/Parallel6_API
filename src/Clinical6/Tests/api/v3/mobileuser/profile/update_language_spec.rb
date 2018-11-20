require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/mobile_users/:id/profile update_language' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:mobile_env_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { mobile_env_user["email"] }
  let(:mobile_user_password) { mobile_env_user["password"] }
  let(:device_id) { mobile_env_user["device_id"] }

  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:super_user_email) { env_user["email"] }
  let(:super_user_password) { env_user["password"] }

#Test Info
  let(:testname) { "mobileuser_update_language" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:language_id) { test_data["language_id"] }
#Requests

  let(:mobile_session) {V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)}
  let(:mobile_user_id) { mobile_session.mobile_user_id }
  let(:token) { V3::Users::Session::Create.new(super_user_email, super_user_password, base_url).token }
  #let(:token) { mobile_session.token }
  let(:mobileuser_update_language) { V3::MobileUser::Profile::UpdateLanguage.new(mobile_user_id, token, super_user_email, base_url, language_id) }

  context 'with valid user' do
    it 'returns 200 and update language of mobile user' do
      expect(mobileuser_update_language.response.code).to eq 200
      expect(JSON.parse(mobileuser_update_language.response).dig('data', 'relationships', 'language', 'data', 'id')).to eq language_id
    end
  end

  context 'with invalid user' do
    let(:mobile_user_id) { test_data["invalid_mobile_user_id"] }
    it 'returns 404 error and Record Not Found in body' do
      expect(mobileuser_update_language.response.code).to eq 404
      expect(mobileuser_update_language.response.body).to match /Record Not Found/
    end
  end

end

