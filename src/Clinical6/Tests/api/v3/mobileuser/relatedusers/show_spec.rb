require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/mobile_users/:id/related_users' do
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
  let(:device_id) {env_mobile_user["device_id"] }
#Test Info
  let(:testname) { "mobileuser_relatedusers" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token}
  let(:mobile_user_id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id }
  let(:mobileuser_relatedusers) { V3::MobileUser::RelatedUsers::Show.new(token, user_email, base_url, mobile_user_id) }

  context 'with valid user' do
    it 'returns 200 and shows the related users of mobile user' do
      expect(mobileuser_relatedusers.response.code).to eq 200
      expect(JSON.parse(mobileuser_relatedusers.response).dig('data', 0, 'id')).not_to eq nil
      expect(JSON.parse(mobileuser_relatedusers.response).dig('data', 0, 'type')).to eq "related_users"
    end
  end

  context 'with invalid id' do
    let(:mobile_user_id) { test_data["invalid_mobile_user_id"] }
    it 'returns 404 error and Record Not Found in body' do
      expect(mobileuser_relatedusers.response.code).to eq 404
      expect(mobileuser_relatedusers.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:mobile_user_id) { test_data["mobile_user_id"] }
    it 'returns 401 error' do
      expect(mobileuser_relatedusers.response.code).to eql 401
      expect(mobileuser_relatedusers.response.body).to match /Authentication Failed/
    end
  end

end

