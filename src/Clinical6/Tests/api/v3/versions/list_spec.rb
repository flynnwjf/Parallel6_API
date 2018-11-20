require_relative '../../../../../../src/spec_helper'

describe 'Get V3/versions' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "versions_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:versions_list){ V3::Versions::List.new(token, user_email, base_url)}

  context 'with valid user' do
    it 'returns 200 and shows versions' do
      expect(versions_list.response.code).to eq 200
      expect(JSON.parse(versions_list.response.body).dig("data", 0, "id")).not_to eq ""
      expect(JSON.parse(versions_list.response.body).dig("data", 0, "type")).to eq "versions"
    end
  end

  context 'with invalid user' do
    let(:user_email) { test_data["invalid_name"] }
    it 'returns 401 error & displays authentication fails in body' do
      expect(versions_list.response.code).to eq 401
      expect(versions_list.response.body).to match /Authentication Failed/
    end
  end

end

