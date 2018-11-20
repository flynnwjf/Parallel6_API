require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/reminder/events' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:env_mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { env_mobile_user["email"] }
  let(:mobile_user_password) { env_mobile_user["password"] }
  let(:device_id) { env_mobile_user["device_id"]}
#Test Info
  let(:testname) { "reminder_event_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:link) { "test_" + Time.new.strftime("%Y_%m_%d_%H_%M_%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:rule_id) { V3::Reminder::Rule::Create.new(token, user_email, base_url, link).id }
  let(:id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id}
  let(:reminder_event_create) { V3::Reminder::Event::Create.new(token, user_email, base_url, rule_id, id) }

  context 'with valid user' do
    it 'returns 201 status code & creates an event' do
      expect(reminder_event_create.response.code).to eq 201
      expect(JSON.parse(reminder_event_create.response).dig('data','type')).to eq "reminder__events"
      expect(JSON.parse(reminder_event_create.response).dig('data', 'id')).not_to eq nil
      #Clean Up
      expect(V3::Reminder::Event::Delete.new(token, user_email, base_url, reminder_event_create.id).response.code).to eq 204
      expect(V3::Reminder::Rule::Delete.new(token, user_email, base_url, rule_id).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:rule_id) { test_data["id"] }
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(reminder_event_create.response.code).to eq 401
      expect(reminder_event_create.response.body).to match /Authentication Failed/
    end
  end

end



