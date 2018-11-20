require_relative '../../../../../../src/spec_helper'

describe 'Post V3/temporary_identifiers' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "temporary_identifiers_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:mobile_user_id) { test_data["mobile_user_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:temporary_identifiers_create) { V3::TemporaryIdentifier::Create.new(token, user_email, base_url, mobile_user_id) }

  context 'with valid user and id' do
    it 'returns 201 status code & creates a temporary identifier' do
      expect(temporary_identifiers_create.response.code).to eq 201
      expect(JSON.parse(temporary_identifiers_create.response).dig('data','type')).to eq "temporary_identifiers"
      expect(JSON.parse(temporary_identifiers_create.response).dig('data', 'attributes','token')).not_to eq ""
    end
  end

  context 'with invalid user' do
    let(:user_email) { test_data["invalid_email"] }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(temporary_identifiers_create.response.code).to eq 401
      expect(temporary_identifiers_create.response.body).to match /Authentication Failed/
    end
  end

end



