require_relative '../../../../../../src/spec_helper'

describe 'PATCH V3/geofences/:id/update' do
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
  let(:testname) { "geofences_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:permanent_link) { test_data["permanent_link"] + Time.new.strftime("_%Y-%m-%d-%H-%M-%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:geofences_update) { V3::Geofences::Update.new(token, user_email, base_url, type, permanent_link, id) }

  context 'with valid user' do
    let(:id) {  V3::Geofences::Create.new(token, user_email, base_url, pre_type, pre_permanent_link).id }
    it 'returns 200 status code' do
      expect(geofences_update.response.code).to eq 200
      expect(JSON.parse(geofences_update.response).dig('data', 'id')).to eq id
      expect(JSON.parse(geofences_update.response).dig('data', 'attributes', 'permanent_link')).to eq permanent_link
      #cleanup
      expect(V3::Geofences::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(geofences_update.response.code).to eq 404
      expect(geofences_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:permanent_link) { test_data["invalid_parameter"] }
    let(:id) { "1" }
    it 'returns 422 error' do
      expect(geofences_update.response.code).to eq 422
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
      expect([403, 404]).to include (geofences_update.response.code)
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
      expect(geofences_update.response.code).to eq 401
      expect(geofences_update.response.body).to match /Authentication Failed/
    end
  end

end



