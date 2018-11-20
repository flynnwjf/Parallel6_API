require_relative '../../../../../../src/spec_helper'

describe 'Get V3/sso_options' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "ssooptions_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:ssooptions_index){ V3::Ssooptions::Index.new(token, user_email, base_url)}

  context 'with valid user' do
    it 'returns 200 and shows sso options' do
      expect(ssooptions_index.response.code).to eq 200
      expect(JSON.parse(ssooptions_index.response.body).dig(0, "permanent_link")).not_to eq ""
      expect(JSON.parse(ssooptions_index.response.body).dig(0, "name")).not_to eq ""
      expect(JSON.parse(ssooptions_index.response.body).dig(0, "user_type")).not_to eq ""
    end
  end

  context 'with invalid user' do
    let(:user_email) { test_data["invalid_name"] }
    it 'returns 200 error because this endpoint should not require authentication' do
      expect(ssooptions_index.response.code).to eq 200
      expect(JSON.parse(ssooptions_index.response.body).dig(0, "permanent_link")).not_to eq ""
      expect(JSON.parse(ssooptions_index.response.body).dig(0, "name")).not_to eq ""
      expect(JSON.parse(ssooptions_index.response.body).dig(0, "user_type")).not_to eq ""
    end
  end

end

