require_relative '../../../../../../src/spec_helper'

describe 'Get V3/rfc_options' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "rfc_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:rfc_show){ V3::RFC::Show.new(token, user_email, base_url)}

  context 'with valid user' do
    it 'returns 200 and shows RFC' do
      expect(rfc_show.response.code).to eq 200
      expect(JSON.parse(rfc_show.response.body).dig("data", 0,"id")).not_to eq nil
      expect(JSON.parse(rfc_show.response.body).dig("data", 0,"type")).to eq "rfc_options"
    end
  end

  context 'with invalid user' do
    let(:user_email) { test_data["invalid_email"] }
    it 'returns 401 error & displays authentication fails in body' do
      expect(rfc_show.response.code).to eq 401
      expect(rfc_show.response.body).to match /Authentication Failed/
    end
  end

end

