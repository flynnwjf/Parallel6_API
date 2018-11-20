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
  let(:testname) { "related_users_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobile_user_id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id}
  let(:related_users_create) { V3::RelatedUsers::Create.new(token, user_email, base_url, mobile_user_id) }

  context 'with valid user' do
    it 'returns 200 status code & creates a related user' do
      expect(related_users_create.response.code).to eq 200
      expect(JSON.parse(related_users_create.response).dig('data','type')).to eq "related_users"
      expect(JSON.parse(related_users_create.response).dig('data', 'id')).not_to eq nil
      #Clean Up
      id = related_users_create.id
      expect(V3::RelatedUsers::Delete.new(token, user_email, base_url, id).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(related_users_create.response.code).to eq 401
      expect(related_users_create.response.body).to match /Authentication Failed/
    end
  end

end



