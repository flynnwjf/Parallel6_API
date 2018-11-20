require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/mobile_users/:id/profile' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)

  let(:env_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:device_id) {env_user["device_id"] }

#Test Info
  let(:testname) { "mobileuser_profile_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:mobile_user_session){ V3::MobileUser::Session::Create.new(user_email, user_password, base_url, device_id)}
  let(:mobile_user_id) { mobile_user_session.mobile_user_id }
  let(:token) { mobile_user_session.token}
  let(:mobileuser_profile_index) { V3::MobileUser::Profile::Show.new(mobile_user_id, token, base_url) }

  context 'with valid user' do
    it 'returns 200 and shows the profile of mobile user' do
      expect(mobileuser_profile_index.response.code).to eq 200
      expect(JSON.parse(mobileuser_profile_index.response).dig('data', 'type')).to eq "profiles"
      #To Do
      #expect(JSON.parse(mobileuser_profile_index.response).dig('data', 'attributes', 'update_at')).to eq ""
    end
  end

  context 'with invalid user' do
    let(:mobile_user_id) { test_data["invalid_mobile_user_id"] }
    it 'returns 404 error and Record Not Found in body' do
      expect(mobileuser_profile_index.response.code).to eq 404
      expect(mobileuser_profile_index.response.body).to match /Record Not Found/
    end
  end

end

