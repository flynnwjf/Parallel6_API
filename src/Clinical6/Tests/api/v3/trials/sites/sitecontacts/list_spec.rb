require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/trials/sites/:site_id/trials/site_contacts' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "trials_sites_sitecontacts_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:site_contacts_list) { V3::Trials::Sites::SiteContacts::List.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:id) { test_data["id"] }
    it 'return 200 code & list site contacts' do
      expect(site_contacts_list.response.code).to eq 200
      expect(JSON.parse(site_contacts_list.response.body).dig("data", 0, "type")).to eq "trials__site_contacts"
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & body to contain Record Not Found message' do
      expect(site_contacts_list.response.code).to eq 404
      expect(site_contacts_list.response.body).to match /Record Not Found/
    end
  end

end

