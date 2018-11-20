require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/reminder/rules/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "reminder_event_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:link) { "test_" + Time.new.strftime("%Y_%m_%d_%H_%M_%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:rule_id) { V3::Reminder::Rule::Create.new(token, user_email, base_url, link).id }
  let(:id) { V3::Reminder::Event::Create.new(token, user_email, base_url, rule_id).id }
  let(:reminder_event_show) { V3::Reminder::Event::Show.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 status code & get an event' do
      expect(reminder_event_show.response.code).to eq 200
      expect(JSON.parse(reminder_event_show.response).dig('data', 'id')).to eq id
      expect(JSON.parse(reminder_event_show.response).dig('data', 'type')).to eq "reminder__events"
      #Clean Up
      expect(V3::Reminder::Event::Delete.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Reminder::Rule::Delete.new(token, user_email, base_url, rule_id).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(reminder_event_show.response.code).to eq 404
      expect(reminder_event_show.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:id) { test_data["id"] }
    let(:rule_id) { test_data["id"] }
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error & Authentication Failed message in body' do
      expect(reminder_event_show.response.code).to eq 401
      expect(reminder_event_show.response.body).to match /Authentication Failed/
    end
  end

end



