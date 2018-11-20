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
  let(:testname) { "trials_sitemember_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:site_member) { test_data["valid_site_member_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:site_member_show) { V3::Trials::SiteMember::Show.new(token, user_email, base_url, site_member) }

  context 'with valid user' do
    it 'returns 200 code and shows site members' do
      expect(site_member_show.response.code).to eq 200
      expect(JSON.parse(site_member_show.response.body).dig("data", "id")).to eq "1"
    end
  end

  context 'with invalid user' do
    let(:site_member) { test_data["invalid_site_member_id"] }
    it 'returns 404 error & Record Not Found' do
      expect(site_member_show.response.code).to eq 404
      expect(site_member_show.response.body).to match /Record Not Found/
    end
  end

end

