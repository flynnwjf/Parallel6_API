require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/trials/site_members' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "trials_sitemember_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:site_member_index) { V3::Trials::SiteMember::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 code and shows site members' do
      expect(site_member_index.response.code).to eq 200
      expect(JSON.parse(site_member_index.response.body).dig("data", 0,"id")).to eq "1"
      expect(JSON.parse(site_member_index.response.body).dig("data", 0,"attributes", "member_type").class).to eq String
    end
  end

  context 'with invalid user' do
    let(:user_email) { test_data["invalid_name"] }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(site_member_index.response.code).to eq 401
      expect(site_member_index.response.body).to match /Authentication Failed/
    end
  end

end

