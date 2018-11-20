require_relative '../../../../../../../src/spec_helper'

describe 'DELETE V3/geofences/:geofence_id/locations/:id/destroy' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  # Geofence creates
  let(:geofence_create_testname) { "geofences_create" }
  let(:geofence_test_data) { DataHandler.get_test_data(geofence_create_testname) }
  let(:geofence_type) { geofence_test_data["type"] }
  let(:geofence_permanent_link) { geofence_test_data["permanent_link"] + Time.new.strftime("_%Y-%m-%d-%H-%M-%S")  }
  # Geofence location creates
  let(:pre_testname) { "geofences_locations_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:title) { pre_test_data["title"] + Time.new.strftime("_%Y-%m-%d-%H-%M-%S") }
  let(:latitude) { pre_test_data["latitude"] }
  let(:longitude) { pre_test_data["longitude"] }
  #Test Info
  let(:testname) { "geofences_locations_destroy" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:geofences_locations_destroy) { V3::Geofences::Locations::Destroy.new(token, user_email, base_url, geofence_id, id)}

  context 'with valid user' do
    let(:geofence_id) { V3::Geofences::Create.new(token, user_email, base_url, geofence_type, geofence_permanent_link).id }
    let(:id) { V3::Geofences::Locations::Create.new(token, user_email, base_url, geofence_id, type, title, latitude, longitude).id }
    it 'returns 204 status code' do
      expect(geofences_locations_destroy.response.code).to eq 204
      #cleanup
      expect(V3::Geofences::Destroy.new(token, user_email, base_url, geofence_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:geofence_id) { "1" }
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(geofences_locations_destroy.response.code).to eq 404
      expect(geofences_locations_destroy.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:geofence_id) { "1" }
    let(:id) { "1" }
    it 'returns 403 or 404 error' do
      expect([403, 404]).to include (geofences_locations_destroy.response.code)
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:geofence_id) { "1" }
    let(:id) { "1" }
    it 'returns 401 error' do
      expect(geofences_locations_destroy.response.code).to eq 401
      expect(geofences_locations_destroy.response.body).to match /Authentication Failed/
    end
  end

end



