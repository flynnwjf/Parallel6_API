require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/consent/forms/:form_version_id/consent/form_versions/list' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_forms_formversions_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:form_version_id) { test_data["form_version_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_forms_formversions_list) { V3::Consent::Forms::FormVesions::List.new(token, user_email, base_url, form_version_id) }

  context 'with valid user' do
    it 'returns 200 status code' do
      expect(consent_forms_formversions_list.response.code).to eq 200
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:form_version_id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(consent_forms_formversions_list.response.code).to eq 404
      expect(consent_forms_formversions_list.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:consent_forms_formversions_list) { V3::Consent::Forms::FormVesions::List.new(token, invalid_user, base_url, form_version_id) }
    it 'returns 401 error' do
      expect(consent_forms_formversions_list.response.code).to eq 401
      expect(consent_forms_formversions_list.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



