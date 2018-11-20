require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/consent/approvers' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_approvers_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:approver_email) { test_data["email"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_approvers_create) { V3::Consent::Approvers::Create.new(token, user_email, base_url, type, approver_email) }
  let(:created_id) { consent_approvers_create.id}

  context 'with valid user' do
    it 'returns 201 status code and creates a consent approver' do
      expect(consent_approvers_create.response.code).to eq 201
      expect(created_id.to_i).to be >=1
      expect(JSON.parse(consent_approvers_create.response.body).dig("data", "type")).to eq type
      expect(JSON.parse(consent_approvers_create.response.body).dig("data", "attributes", "email")).to eq approver_email
      #cleanup
      expect(V3::Consent::Approvers::Destroy.new(token, user_email, base_url, created_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:approver_email) { test_data["invalid_email"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(consent_approvers_create.response.code).to eq 422
      expect(consent_approvers_create.response.body).to match /can't be blank/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:consent_approvers_create) { V3::Consent::Approvers::Create.new(token, invalid_user, base_url, type, approver_email) }
    it 'returns 401 error' do
      expect(consent_approvers_create.response.code).to eq 401
      expect(consent_approvers_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end

