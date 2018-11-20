require_relative '../../../../../../src/spec_helper'

describe 'Get V3/saml_configurations' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "saml_configurations_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:saml_configurations_index){ V3::SamlConfigurations::Index.new(token, user_email, base_url)}

  context 'with valid user' do
    it 'returns 200 and shows SAML Configurations' do
      expect(saml_configurations_index.response.code).to eq 200
      expect(JSON.parse(saml_configurations_index.response.body).dig("data", 0,"id")).not_to eq nil
      expect(JSON.parse(saml_configurations_index.response.body).dig("data", 0,"type")).to eq "saml_configurations"
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(saml_configurations_index.response.code).to eql 401
      expect(saml_configurations_index.response.body).to match /Authentication Failed/
    end
  end

end

