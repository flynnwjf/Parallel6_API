require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/consent/approver_assignments' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_approver_assignments_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_approver_assignments_create) { V3::Consent::ApproverAssignments::Create.new(token, user_email, base_url, approver_id, group_id) }
  let(:consent_approver_assignments_del) { V3::Consent::ApproverAssignments::Delete.new(token, user_email, base_url, id) }
  let(:id) { consent_approver_assignments_create.id }

  context 'with valid user' do
    let(:approver_id) { test_data["approver_id"] }
    let(:group_id) { test_data["group_id"] }
    it 'returns 201 code and create consent approver assignments' do
      expect(consent_approver_assignments_create.response.code).to eq 201
      expect(JSON.parse(consent_approver_assignments_create.response.body).dig("data", "type")).to eq "consent__approver_assignments"
      #CleanUp to avoid taken data
      expect(consent_approver_assignments_del.response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:approver_id) { test_data["invalid_approver_id"] }
    let(:group_id) { test_data["invalid_group_id"] }
    it 'returns 422 error & Invalid parameters message in body' do
      expect(consent_approver_assignments_create.response.code).to eq 422
      expect(consent_approver_assignments_create.response.body).to match /Invalid parameters/
    end
  end

end

