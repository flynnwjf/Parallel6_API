require_relative '../../../../../../src/spec_helper'

describe 'Post V3/geofences/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "geofences_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:permanent_link) { test_data["permanent_link"] + Time.new.strftime("_%Y-%m-%d-%H-%M-%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:geofences_create) { V3::Geofences::Create.new(token, user_email, base_url, type, permanent_link) }
  let(:created_id) { geofences_create.id}

  context 'with valid user' do
    it 'returns 201 status code ' do
      expect(geofences_create.response.code).to eq 201
      expect(JSON.parse(geofences_create.response).dig('data', 'type')).to eq type
      expect(JSON.parse(geofences_create.response).dig('data', 'attributes','permanent_link')).to eq permanent_link
      #cleanup
      expect(V3::Geofences::Destroy.new(token, user_email, base_url, created_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:permanent_link) { test_data["invalid_parameter"] }
    it 'returns 422 error' do
      expect(geofences_create.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 403 error' do
      expect(geofences_create.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 401 error' do
      expect(geofences_create.response.code).to eq 401
      expect(geofences_create.response.body).to match /Authentication Failed/
    end
  end

end



