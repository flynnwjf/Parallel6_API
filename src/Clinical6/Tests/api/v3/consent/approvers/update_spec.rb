require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/consent/approvers/:id/update' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "consent_approvers_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:approver_email) { pre_test_data["email"] }
#Test Info
  let(:testname) { "consent_approvers_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:update_email) { test_data["email"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_approvers_update) { V3::Consent::Approvers::Update.new(token, user_email, base_url, id, update_email) }

  context 'with valid user' do
    let(:consent_approvers_create) { V3::Consent::Approvers::Create.new(token, user_email, base_url, type, approver_email) }
    let(:id) { consent_approvers_create.id }
    it 'returns 200 status code' do
      expect(consent_approvers_create.response.code).to eq 201
      expect(consent_approvers_update.response.code).to eq 200
      expect(JSON.parse(consent_approvers_update.response).dig('data', 'id')).to eq id
      expect(JSON.parse(consent_approvers_update.response).dig("data", "attributes", "email")).to eq update_email
      #cleanup
      expect(V3::Consent::Approvers::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do

      expect(consent_approvers_update.response.code).to eq 404
      expect(consent_approvers_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:update_email) { test_data["invalid_email"] }
    let(:consent_approvers_create) { V3::Consent::Approvers::Create.new(token, user_email, base_url, type, approver_email) }
    let(:id) { consent_approvers_create.id }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(consent_approvers_update.response.code).to eq 422
      expect(consent_approvers_update.response.body).to match /can't be blank/
      #cleanup
      expect(V3::Consent::Approvers::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:id) { "1" }
    let(:consent_approvers_update) { V3::Consent::Approvers::Update.new(token, invalid_user, base_url, id, update_email) }
    it 'returns 401 error' do
      expect(consent_approvers_update.response.code).to eq 401
      expect(consent_approvers_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



