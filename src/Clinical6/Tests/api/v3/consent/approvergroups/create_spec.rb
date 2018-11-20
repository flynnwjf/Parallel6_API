require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/consent/approver_groups' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_approver_groups_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:consent_approver_groups_create) { V3::Consent::ApproverGroups::Create.new(token, user_email, base_url, name) }

  context 'with valid user' do
    let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
    it 'returns 201 code and create consent approver group' do
      expect(consent_approver_groups_create.response.code).to eq 201
      expect(JSON.parse(consent_approver_groups_create.response.body).dig("data", "type")).to eq "consent__approver_groups"
      expect(JSON.parse(consent_approver_groups_create.response.body).dig("data", "attributes", "name")).to eq name
    end
  end

  context 'with invalid name' do
    let(:name) { test_data["invalid_name"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(consent_approver_groups_create.response.code).to eq 422
      expect(consent_approver_groups_create.response.body).to match /can't be blank/
    end
  end

end

