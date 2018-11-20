require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/mobile_users/:id/data_collection/captured_value_groups/:id' do
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
  let(:testname) { "mobileuser_datacollection_capturedvaluegroups_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobile_user_id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id}
  let(:id) { V3::MobileUser::DataCollection::CapturedValueGroups::Index.new(token, user_email, base_url, mobile_user_id).id }
  let(:mobileuser_datacollection_capturedvaluegroups_show) { V3::MobileUser::DataCollection::CapturedValueGroups::Show.new(token, user_email, base_url, mobile_user_id, id) }

  context 'with valid user' do
    it 'returns 200 OK status code' do
      expect(mobileuser_datacollection_capturedvaluegroups_show.response.code).to eq 200
      expect(JSON.parse(mobileuser_datacollection_capturedvaluegroups_show.response).dig('data', 'id')).to eq id
      expect(JSON.parse(mobileuser_datacollection_capturedvaluegroups_show.response).dig('data', 'type')).to eq "data_collection__captured_value_groups"
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(mobileuser_datacollection_capturedvaluegroups_show.response.code).to eq 404
      expect(mobileuser_datacollection_capturedvaluegroups_show.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(mobileuser_datacollection_capturedvaluegroups_show.response.code).to eq 401
      expect(mobileuser_datacollection_capturedvaluegroups_show.response.body).to match /Authentication Failed/
    end
  end

end

