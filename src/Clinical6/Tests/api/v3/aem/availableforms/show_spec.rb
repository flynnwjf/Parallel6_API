require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/mobile_users/#{mobile_user_id}/aem/available_forms' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:env_mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { env_mobile_user["email"] }
  let(:mobile_user_password) { env_mobile_user["password"] }
  let(:device_id) { env_mobile_user["device_id"]}
#Test Info
  let(:testname) { "aem_availableforms_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id}
  let(:aem_availableforms_show) { V3::AEM::AvailableForms::Show.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 status code & shows aem available forms' do
      expect(aem_availableforms_show.response.code).to eq 200
      if !JSON.parse(aem_availableforms_show.response).dig('data', 0, 'id').eql? nil
        expect(JSON.parse(aem_availableforms_show.response).dig('data', 0, 'type')).to eq "aem__available_forms"
      end
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(aem_availableforms_show.response.code).to eql 401
      expect(aem_availableforms_show.response.body).to match /Authentication Failed/
    end
  end

end



