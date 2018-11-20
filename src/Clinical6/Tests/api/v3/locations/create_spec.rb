require_relative '../../../../../../src/spec_helper'

describe 'Post V3/locations' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "locations_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:title) { test_data["title"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:locations_create) { V3::Locations::Create.new(token, user_email, base_url, title) }

  context 'with valid user' do
    it 'returns 201 status code & creates a location' do
      expect(locations_create.response.code).to eq 201
      expect(JSON.parse(locations_create.response).dig('data','id')).not_to eq nil
      expect(JSON.parse(locations_create.response).dig('data', 'type')).to eq "locations"
      expect(JSON.parse(locations_create.response).dig('data', 'attributes', 'title')).to eq title
      #Clean Up
      id = JSON.parse(locations_create.response).dig('data','id')
      expect(V3::Locations::Delete.new(token, user_email, base_url, id).response.code).to eq 204
    end
  end

  context 'with valid user and invalid name' do
    let(:title) { test_data["invalid_title"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(locations_create.response.code).to eq 422
      expect(locations_create.response.body).to match /can\'t be blank/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(locations_create.response.code).to eql 401
      expect(locations_create.response.body).to match /Authentication Failed/
    end
  end

end



