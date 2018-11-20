require_relative '../../../../../../../src/spec_helper'

describe 'Delete V3/consent/approvers/:id/destroy' do
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
  let(:testname) { "consent_approvers_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_approvers_destroy) { V3::Consent::Approvers::Destroy.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:consent_approvers_create) { V3::Consent::Approvers::Create.new(token, user_email, base_url, type, approver_email) }
    let(:id) { consent_approvers_create.id }
    it 'returns 204 status code' do
      expect(consent_approvers_create.response.code).to eq 201
      expect(consent_approvers_destroy.response.code).to eq 204
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(consent_approvers_destroy.response.code).to eq 404
      expect(consent_approvers_destroy.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:id) { "1" }
    let(:consent_approvers_destroy) { V3::Consent::Approvers::Destroy.new(token, invalid_user, base_url, id) }
    it 'returns 401 error' do
      expect(consent_approvers_destroy.response.code).to eq 401
      expect(consent_approvers_destroy.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



