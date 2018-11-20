require_relative '../../../../../../../../src/spec_helper'

describe 'Delete V3/mobile_users/:id/consent/consent' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { mobile_user["email"] }
  let(:mobile_user_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
#Test Info
  let(:testname) { "mobileuser_consent_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id }
  let(:mobileuser_consent_delete) { V3::MobileUser::Consent::Consent::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 204 and deletes the consent of mobile user' do
      expect(mobileuser_consent_delete.response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error and Record Not Found in body' do
      expect(mobileuser_consent_delete.response.code).to eq 404
      expect(mobileuser_consent_delete.response.body).to match /Record Not Found/
    end
  end

end

