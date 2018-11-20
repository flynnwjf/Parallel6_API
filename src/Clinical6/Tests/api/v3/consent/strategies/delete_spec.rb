require_relative '../../../../../../../src/spec_helper'

describe 'Delete V3/consent/strategies/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_strategies_del" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) {test_data["id"]}
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:consent_strategies_id) { V3::Consent::Strategies::Create.new(token, user_email, base_url, name, id).consent_strategies_id }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_strategies_del) { V3::Consent::Strategies::Delete.new(token, user_email, base_url, consent_strategies_id) }

  context 'with valid user' do
    it 'returns 204 code and deletes consent strategies' do
      expect(consent_strategies_del.response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:consent_strategies_id) { test_data["invalid_consent_strategies_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(consent_strategies_del.response.code).to eq 404
      expect(consent_strategies_del.response.body).to match /Record Not Found/
    end
  end

end

