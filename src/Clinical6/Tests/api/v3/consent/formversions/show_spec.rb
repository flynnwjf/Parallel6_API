require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/consent/form_versions/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_formversions_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_formversions_show) { V3::Consent::FormVersions::Show.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:id) { V3::Consent::FormVersions::Index.new(token, user_email, base_url).id }
    it 'returns 200 code and shows consent form versions' do
      DataHandler.change_test_data_value(testname, "id", id)
      expect(consent_formversions_show.response.code).to eq 200
      expect(JSON.parse(consent_formversions_show.response.body).dig("data", "id")).to eq id
      expect(JSON.parse(consent_formversions_show.response.body).dig("data", "type")).to eq "consent__form_versions"
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 Record Not Found' do
      expect(consent_formversions_show.response.code).to eql 404
      expect(consent_formversions_show.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:id) { test_data["id"] }
    it 'returns 401 error' do
      expect(consent_formversions_show.response.code).to eql 401
      expect(consent_formversions_show.response.body).to match /Authentication Failed/
    end
  end

end

