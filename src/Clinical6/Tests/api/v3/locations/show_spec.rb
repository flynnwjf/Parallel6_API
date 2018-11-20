require_relative '../../../../../../src/spec_helper'

describe 'Get V3/locations/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "locations_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::Locations::Index.new(token, user_email, base_url).id }
  let(:locations_show) { V3::Locations::Show.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 status code & shows the locations' do
      expect(locations_show.response.code).to eq 200
      expect(JSON.parse(locations_show.response.body).dig("data","id")).to eq id
      expect(JSON.parse(locations_show.response.body).dig("data","type")).to eq "locations"
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(locations_show.response.code).to eq 404
      expect(locations_show.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:id) { test_data["id"] }
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(locations_show.response.code).to eql 401
      expect(locations_show.response.body).to match /Authentication Failed/
    end
  end

end



