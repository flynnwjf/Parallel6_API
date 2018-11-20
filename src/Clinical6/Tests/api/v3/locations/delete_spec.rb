require_relative '../../../../../../src/spec_helper'

describe 'Delete V3/locations/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "locations_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:title) { test_data["title"]}
  let(:id) { V3::Locations::Create.new(token, user_email, base_url, title).id }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:locations_delete) { V3::Locations::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 204 status code & deletes the location' do
      expect(locations_delete.response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(locations_delete.response.code).to eq 404
      expect(locations_delete.response.body).to match /Record Not Found/
    end
  end

end



