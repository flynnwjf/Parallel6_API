require_relative '../../../../../../src/spec_helper'

describe 'Get V3/temporary_identifiers/:identifier' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "temporary_identifiers_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:mobile_user_id) { test_data["mobile_user_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:identifier) { V3::TemporaryIdentifier::Create.new(token, user_email, base_url, mobile_user_id).identifier }
  let(:temporary_identifiers_show) { V3::TemporaryIdentifier::Show.new(token, user_email, base_url, identifier) }

  context 'with valid user' do
    it 'returns 200 code and shows temporary identifier' do
      expect(temporary_identifiers_show.response.code).to eq 200
      expect(JSON.parse(temporary_identifiers_show.response.body).dig("data", "attributes", "token")).to eq identifier
    end
  end

  context 'with invalid id' do
    let(:identifier) { test_data["invalid_identifier"] }
    it 'returns 404 error & Record Not Found' do
      expect(temporary_identifiers_show.response.code).to eq 404
      expect(temporary_identifiers_show.response.body).to match /Record Not Found/
    end
  end

end

