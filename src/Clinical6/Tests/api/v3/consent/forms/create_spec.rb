require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/consent/forms' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_forms_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::Consent::Strategies::Index.new(token, user_email, base_url).id }
  let(:name) { "TestForm-" + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:consent_forms_create) { V3::Consent::Forms::Create.new(token, user_email, base_url, id, name) }

  context 'with valid user' do
    it 'returns 201 code and creates consent forms' do
      expect(consent_forms_create.response.code).to eq 201
      expect(JSON.parse(consent_forms_create.response.body).dig("data", "id")).not_to eq nil
      expect(JSON.parse(consent_forms_create.response.body).dig("data", "type")).to eq "consent__forms"
      expect(JSON.parse(consent_forms_create.response.body).dig("data", "attributes", "name")).to eq name
    end
  end

  context 'with invalid id' do
    let(:id) {test_data["invalid_id"]}
    it 'returns 422 error & Invalid parameters message in body' do
      expect(consent_forms_create.response.code).to eq 422
      expect(consent_forms_create.response.body).to match /Invalid parameters/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:id) {test_data["id"]}
    it 'returns 401 error' do
      expect(consent_forms_create.response.code).to eql 401
      expect(consent_forms_create.response.body).to match /Authentication Failed/
    end
  end

end

