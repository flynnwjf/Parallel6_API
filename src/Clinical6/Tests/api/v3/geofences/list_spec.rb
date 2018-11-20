require_relative '../../../../../../src/spec_helper'

describe 'GET V3/geofences/list' do
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
  let(:testname) { "geofences_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:geofences_list) { V3::Genfences::List.new(token, user_email, base_url) }

  context 'with valid user' do
    let(:geofences_create) { V3::Geofences::Create.new(token, user_email, base_url, type, permanent_link) }
    it 'returns 200 status code' do
      expect(geofences_create.response.code).to eq 201
      expect(geofences_list.response.code).to eq 200
      #cleanup
      expect(V3::Geofences::Destroy.new(token, user_email, base_url, geofences_create.id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 403 or 404 error' do
      expect([403, 404]).to include (geofences_list.response.code)
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 401 error' do
      expect(geofences_list.response.code).to eq 401
      expect(geofences_list.response.body).to match /Authentication Failed/
    end
  end

end



