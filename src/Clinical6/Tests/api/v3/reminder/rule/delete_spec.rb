require_relative '../../../../../../../src/spec_helper'

describe 'Delete V3/reminder/rules' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "reminder_rule_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:link) { "test_" + Time.new.strftime("%Y_%m_%d_%H_%M_%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::Reminder::Rule::Create.new(token, user_email, base_url, link).id }
  let(:reminder_rule_delete) { V3::Reminder::Rule::Delete.new(token, user_email, base_url, id) }


  context 'with valid user' do
    it 'returns 204 status code & deletes a rule' do
      expect(reminder_rule_delete.response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(reminder_rule_delete.response.code).to eq 404
      expect(reminder_rule_delete.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:id) { test_data["id"] }
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(reminder_rule_delete.response.code).to eq 401
      expect(reminder_rule_delete.response.body).to match /Authentication Failed/
    end
  end

end



