require_relative '../../../../../../../src/spec_helper'

describe 'POST V3/geofences/:id/locations/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "geofences_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:pre_type) { pre_test_data["type"] }
  let(:pre_permanent_link) { pre_test_data["permanent_link"] + Time.new.strftime("_%Y-%m-%d-%H-%M-%S")  }
#Test Info
  let(:testname) { "geofences_locations_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] + Time.new.strftime("_%Y-%m-%d-%H-%M-%S") }
  let(:latitude) { test_data["latitude"] }
  let(:longitude) { test_data["longitude"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:geofences_locations_create) { V3::Geofences::Locations::Create.new(token, user_email, base_url, geofence_id, type, title, latitude, longitude) }
  let(:created_id) { geofences_locations_create.id}

  context 'with valid user' do
    let(:geofence_id) { V3::Geofences::Create.new(token, user_email, base_url, pre_type, pre_permanent_link).id}
    it 'returns 201 status code ' do
      expect(geofences_locations_create.response.code).to eq 201
      expect(JSON.parse(geofences_locations_create.response).dig('data', 'type')).to eq type
      expect(JSON.parse(geofences_locations_create.response).dig('data', 'attributes','title')).to eq title
      expect(JSON.parse(geofences_locations_create.response).dig('data', 'attributes','latitude')).to eq latitude
      expect(JSON.parse(geofences_locations_create.response).dig('data', 'attributes','longitude')).to eq longitude
      #cleanup
      expect(V3::Geofences::Locations::Destroy.new(token, user_email, base_url, geofence_id, created_id).response.code).to eq 204
      expect(V3::Geofences::Destroy.new(token, user_email, base_url, geofence_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:geofence_id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(geofences_locations_create.response.code).to eq 404
      expect(geofences_locations_create.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:geofence_id) { "1" }
    it 'returns 403 error' do
      expect(geofences_locations_create.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:geofence_id) { "1" }
    it 'returns 401 error' do
      expect(geofences_locations_create.response.code).to eq 401
      expect(geofences_locations_create.response.body).to match /Authentication Failed/
    end
  end

end



