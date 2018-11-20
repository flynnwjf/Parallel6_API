require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/users/:id/sites' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "users_sites_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:site_id) { test_data["id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::Trials::Sites::SiteUsers::Index.new(token, user_email, base_url, site_id).user_id }
  let(:users_sites_show) { V3::Users::Sites::Show.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 status code' do
      expect(users_sites_show.response.code).to eq 200
      expect(JSON.parse(users_sites_show.response).dig('data', 0, 'id')).to eq site_id
      expect(JSON.parse(users_sites_show.response).dig('data', 0, 'type')).to eq "trials__sites"
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(users_sites_show.response.code).to eq 404
      expect(users_sites_show.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(users_sites_show.response.code).to eq 401
      expect(users_sites_show.response.body).to match /Authentication Failed/
    end
  end

end



