require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/mobile_users/:id/genisis/va_appointments/list' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "mobileuser_genisis_vaappointments_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobileuser_genisis_vaappointments_list) { V3::MobileUser::Genisis::VaAppointments::List.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 status code', :mvp_test do
      expect(mobileuser_genisis_vaappointments_list.response.code).to eq 200
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body', :mvp_test  do
      expect(mobileuser_genisis_vaappointments_list.response.code).to eq 404
      expect(mobileuser_genisis_vaappointments_list.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:mobileuser_genisis_vaappointments_list) { V3::MobileUser::Genisis::VaAppointments::List.new(token, invalid_user, base_url, id) }
    it 'returns 401 error', :mvp_test  do
      expect(mobileuser_genisis_vaappointments_list.response.code).to eq 401
      expect(mobileuser_genisis_vaappointments_list.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 403 error', :mvp_test  do
      expect(mobileuser_genisis_vaappointments_list.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



