require_relative '../../../../../../src/spec_helper'

describe 'Post V3/related_users' do
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
  let(:testname) { "related_users_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobile_user_id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id}
  let(:id) { V3::RelatedUsers::Create.new(token, user_email, base_url, mobile_user_id).id }
  let(:related_users_delete) { V3::RelatedUsers::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 204 status code & deletes a related user' do
      expect(related_users_delete.response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(related_users_delete.response.code).to eq 404
      expect(related_users_delete.response.body).to match /Record Not Found/
    end
  end

end



