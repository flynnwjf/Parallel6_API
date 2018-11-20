require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/users/:id/profile/show' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "user_profile_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:id) { V3::Users::Session::Create.new(user_email, user_password, base_url).user_id }
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:profile_show) { V3::Users::Profile::Show.new(id, token, user_email, base_url) }


  context 'with valid user' do
    it 'returns 200 status code & shows profile id for the user' do
      expect(profile_show.response.code).to eq 200
      expect(JSON.parse(profile_show.response).dig('included', 0, 'id')).to eq "#{id}"
    end
  end

  context 'with invalid user' do
    let(:user_email) { test_data["invalid_email"] }
    it 'returns 401 error' do
      expect(profile_show.response.code).to eq 401
      expect(profile_show.response.body).to match /Authentication Failed/
    end
  end

  context 'with invalid profile id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(profile_show.response.code).to eq 404
      expect(profile_show.response.body).to match /Record Not Found/
    end

  end
end



