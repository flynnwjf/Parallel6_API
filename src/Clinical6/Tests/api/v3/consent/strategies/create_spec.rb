require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/consent/strategies' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_strategies_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_strategies_create) { V3::Consent::Strategies::Create.new(token, user_email, base_url, name, id) }

  context 'with valid user' do
    let(:id) {test_data["id"]}
    it 'returns 201 code and create consent strategies' do
      expect(consent_strategies_create.response.code).to eq 201
      expect(JSON.parse(consent_strategies_create.response.body).dig("data", "attributes", "name")).to eq name
    end
  end

  context 'with invalid parameter' do
    let(:id) {test_data["invalid_id"]}
    it 'returns 422 error & Invalid parameters message in body' do
      expect(consent_strategies_create.response.code).to eq 422
      expect(consent_strategies_create.response.body).to match /Invalid parameters/
    end
  end

end

