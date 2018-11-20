require_relative '../../../../../../src/spec_helper'

describe 'GET V3/geofences/:id/show' do
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
  let(:type) { pre_test_data["type"] }
  let(:permanent_link) { pre_test_data["permanent_link"] + Time.new.strftime("_%Y-%m-%d-%H-%M-%S")  }
#Test Info
  let(:testname) { "geofences_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:geofences_show) { V3::Geofences::Show.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:id) {  V3::Geofences::Create.new(token, user_email, base_url, type, permanent_link).id }
    it 'returns 200 status code' do
      expect(geofences_show.response.code).to eq 200
      expect(JSON.parse(geofences_show.response).dig('data', 'id')).to eq id
      #cleanup
      expect(V3::Geofences::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(geofences_show.response.code).to eq 404
      expect(geofences_show.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:id) { "1" }
    it 'returns 403 or 404 error' do
      expect([403, 404]).to include (geofences_show.response.code)
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:id) { "1" }
    it 'returns 401 error' do
      expect(geofences_show.response.code).to eq 401
      expect(geofences_show.response.body).to match /Authentication Failed/
    end
  end

end



