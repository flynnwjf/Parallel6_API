require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/trials/sites/:site_id/site_users/:user_id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "trials_sites_siteusers_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:site_id) { test_data["id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:user_id) { V3::Trials::Sites::SiteUsers::Index.new(token, user_email, base_url, site_id).user_id }
  let(:trials_sites_siteusers_show) { V3::Trials::Sites::SiteUsers::Show.new(token, user_email, base_url, site_id, user_id) }

  context 'with valid user' do
    it 'return 200 code & show site user' do
      puts user_id
      expect(trials_sites_siteusers_show.response.code).to eq 200
      expect(JSON.parse(trials_sites_siteusers_show.response.body).dig("data", "id")).to eq (site_id.to_s + "_" + user_id.to_s)
      expect(JSON.parse(trials_sites_siteusers_show.response.body).dig("data", "type")).to eq "cr_trials__site_users"
    end
  end

  context 'with invalid id' do
    let(:user_id) { test_data["invalid_id"] }
    it 'returns 404 error & body to contain Record Not Found message' do
      expect(trials_sites_siteusers_show.response.code).to eq 404
      expect(trials_sites_siteusers_show.response.body).to match /Record Not Found/
    end
  end

end

