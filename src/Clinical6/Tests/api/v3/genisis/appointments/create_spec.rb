require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/genisis/appointments/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "genisis_appointments_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:genisis_id) { test_data["genisis_id"] }
  let(:mobile_user_id) { test_data["mobile_user_id"] }
  let(:start_time) { DateTime.now.strftime('%FT%H:00:00').to_s }
  let(:end_time) { DateTime.now.strftime('%FT').to_s + (DateTime.now.strftime('%H').to_i + 1).to_s + ":00:00" }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:genisis_appointments_create) { V3::Genisis::Appointments::Create.new(token, user_email, base_url, type, genisis_id, mobile_user_id, start_time, end_time) }

  context 'with valid user' do
    it 'returns 200 status code',:mvp_test do
      expect(genisis_appointments_create.response.code).to eq 200
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:genisis_id) { test_data["invalid_genisis_id"] }
    it 'returns 422 error', :mvp_test do
      expect(genisis_appointments_create.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 403 error',:mvp_test do
      expect(genisis_appointments_create.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

   context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:genisis_appointments_create) { V3::Genisis::Appointments::Create.new(token, invalid_user, base_url, type, genisis_id, mobile_user_id, start_time, end_time) }
    it 'returns 401 error',:mvp_test do
      expect(genisis_appointments_create.response.code).to eq 401
      expect(genisis_appointments_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end

