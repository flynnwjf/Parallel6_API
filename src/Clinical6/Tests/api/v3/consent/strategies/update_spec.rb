require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/consent/strategies/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_strategies_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_strategies_update) { V3::Consent::Strategies::Update.new(token, user_email, base_url, id, name) }

  context 'with valid user' do
    let(:id) {test_data["id"]}
    it 'returns 200 code and updates consent strategies' do
      expect(consent_strategies_update.response.code).to eq 200
      expect(JSON.parse(consent_strategies_update.response.body).dig("data", "attributes", "name")).to eq name
    end
  end

  context 'with invalid id' do
    let(:id) {test_data["invalid_id"]}
    it 'returns 404 error & Record Not Found message in body' do
      expect(consent_strategies_update.response.code).to eq 404
      expect(consent_strategies_update.response.body).to match /Record Not Found/
    end
  end

end

