require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/consent/form_versions/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_formversions_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::Consent::FormVersions::Index.new(token, user_email, base_url).id }
  let(:agreement_template_id) { V3::Agreement::Templates::List.new(token, user_email, base_url).id }
  let(:consent_formversions_update) { V3::Consent::FormVersions::Update.new(token, user_email, base_url, id, agreement_template_id) }

  context 'with valid user' do
    it 'returns 200 code and updates consent form version' do
      expect(consent_formversions_update.response.code).to eq 201
      expect(JSON.parse(consent_formversions_update.response.body).dig("data", "id")).to eq id
      expect(JSON.parse(consent_formversions_update.response.body).dig("data", "relationships", "agreement_template", "data", "id")).to eq agreement_template_id
    end
  end

  context 'with invalid id' do
    let(:id) {test_data["invalid_id"]}
    it 'returns 404 error & Record Not Found message in body' do
      expect(consent_formversions_update.response.code).to eq 404
      expect(consent_formversions_update.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:id) {test_data["id"]}
    let(:agreement_template_id) {test_data["id"]}
    it 'returns 401 error' do
      expect(consent_formversions_update.response.code).to eql 401
      expect(consent_formversions_update.response.body).to match /Authentication Failed/
    end
  end

end

