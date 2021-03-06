require_relative '../../../../../../../src/spec_helper'

describe 'Delete V3/consent/approver_assignments/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_approver_assignments_del" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:approver_id) {test_data["approver_id"]}
  let(:group_id) {test_data["group_id"]}
  #Requests
  let(:id) { V3::Consent::ApproverAssignments::Create.new(token, user_email, base_url, approver_id, group_id).id }
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_approver_assignments_del) { V3::Consent::ApproverAssignments::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 204 code and deletes consent approver assignments' do
      expect(consent_approver_assignments_del.response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(consent_approver_assignments_del.response.code).to eq 404
      expect(consent_approver_assignments_del.response.body).to match /Record Not Found/
    end
  end

end

