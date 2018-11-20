require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/consent/form_versions/:form_version_id/consent/approver_group_assignments/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_forms_approvergroupassignments_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:form_version_id) { test_data["form_version_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:group_id) { V3::Consent::Forms::ApproverGroupAssignments::List.new(token, user_email, base_url, form_version_id).group_id }
  let(:consent_forms_approvergroupassignments_show) { V3::Consent::Forms::ApproverGroupAssignments::Show.new(token, user_email, base_url, form_version_id, group_id) }

  context 'with valid user' do
    it 'returns 200 status code' do
      expect(consent_forms_approvergroupassignments_show.response.code).to eq 200
      expect(JSON.parse(consent_forms_approvergroupassignments_show.response).dig('data', 'id')).to eq group_id
      expect(JSON.parse(consent_forms_approvergroupassignments_show.response).dig('data', 'type')).to eq "consent__approver_group_assignments"
    end
  end

  context 'with invalid id' do
    let(:group_id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(consent_forms_approvergroupassignments_show.response.code).to eq 404
      expect(consent_forms_approvergroupassignments_show.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:group_id) { test_data["id"] }
    it 'returns 401 error' do
      expect(consent_forms_approvergroupassignments_show.response.code).to eq 401
      expect(consent_forms_approvergroupassignments_show.response.body).to match /Authentication Failed/
    end
  end

end



