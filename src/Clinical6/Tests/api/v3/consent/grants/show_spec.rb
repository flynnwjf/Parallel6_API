require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/consent/grants/:id/show' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Other User(s)
  let(:env_unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { env_unauthorized_user["email"] }
  let(:unauthorized_user_password) { env_unauthorized_user["password"] }
#Test Info
  let(:testname) { "consent_grants_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }

#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_grants_show) { V3::Consent::Grants::Show.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 status code' do
      expect(consent_grants_show.response.code).to eq 200
      #expect(JSON.parse(consent_grants_show.response).dig('data', 'id')).to eq id
      #cleanup
      #expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(consent_grants_show.response.code).to eq 404
      expect(consent_grants_show.response.body).to match /Record Not Found/
      #cleanup
      #expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:consent_grants_show) { V3::Consent::Grants::Show.new(token, invalid_user, base_url, id) }
    it 'returns 401 error' do
      expect(consent_grants_show.response.code).to eq 401
      expect(consent_grants_show.response.body).to match /Authentication Failed/
      #cleanup
      #expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:other_token) { V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url).token }
    let(:consent_grants_show) { V3::Consent::Grants::Show.new(other_token, unauthorized_user_email, base_url, id) }
    it 'returns 403 or 404 error' do
      expect([403, 404]).to include (consent_grants_show.response.code)
      if (consent_grants_show.response.code == 403)
        expect(consent_grants_show.response.body).to match /Authorization Failure/
      end
      #cleanup
      #expect(V3::Users::Session::Delete.new(other_token, unauthorized_user_email, base_url).response.code).to eq 204
    end
  end

end



