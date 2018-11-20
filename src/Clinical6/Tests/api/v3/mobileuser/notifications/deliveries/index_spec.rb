require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/mobile_users/:id/notifications/deliveries' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:env_mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { env_mobile_user["email"] }
  let(:mobile_user_password) { env_mobile_user["password"] }
  let(:device_id) { env_mobile_user["device_id"]}
#Test Info
  let(:testname) { "mobileuser_notifications_deliveries_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id}
  let(:mobileuser_notifications_deliveries_index) { V3::MobileUser::Notifications::Deliveries::Index.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 OK status code' do
      expect(mobileuser_notifications_deliveries_index.response.code).to eq 200
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(mobileuser_notifications_deliveries_index.response.code).to eq 404
      expect(mobileuser_notifications_deliveries_index.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(mobileuser_notifications_deliveries_index.response.code).to eq 401
      expect(mobileuser_notifications_deliveries_index.response.body).to match /Authentication Failed/
    end
  end

end

