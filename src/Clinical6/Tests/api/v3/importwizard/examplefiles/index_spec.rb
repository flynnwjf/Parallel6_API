require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/import_wizard/example_files/index' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "importwizard_examplefiles_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:importwizard_examplefiles_index) { V3::ImportWizard::ExampleFiles::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 OK status code' do
      expect(importwizard_examplefiles_index.response.code).to eq 200
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(importwizard_examplefiles_index.response.code).to eq 401
      expect(importwizard_examplefiles_index.response.body).to match /Authentication Failed/
     end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    it 'returns 403 error' do
      expect(importwizard_examplefiles_index.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end

