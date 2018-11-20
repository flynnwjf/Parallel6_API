require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/reminder/rules' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "reminder_rule_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:link) { "test_" + Time.new.strftime("%Y_%m_%d_%H_%M_%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:reminder_rule_create) { V3::Reminder::Rule::Create.new(token, user_email, base_url, link) }

  context 'with valid user' do
    it 'returns 201 status code & creates a rule' do
      expect(reminder_rule_create.response.code).to eq 201
      expect(JSON.parse(reminder_rule_create.response).dig('data','attributes', 'permanent_link')).to eq link
      expect(JSON.parse(reminder_rule_create.response).dig('data','type')).to eq "reminder__rules"
      expect(JSON.parse(reminder_rule_create.response).dig('data', 'id')).not_to eq nil
      #Clean Up
      id = reminder_rule_create.id
      expect(V3::Reminder::Rule::Delete.new(token, user_email, base_url, id).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(reminder_rule_create.response.code).to eq 401
      expect(reminder_rule_create.response.body).to match /Authentication Failed/
    end
  end

end



