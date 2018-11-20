require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
  let(:env_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { env_user["email"] }
  let(:mobile_user_password) { env_user["password"] }
  let(:device_id) { env_user["device_id"] }
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:testname) { "reminder_event_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:link) { "test_" + Time.new.strftime("%Y_%m_%d_%H_%M_%S") }


  it 'C14077 The system allows users to define events(i.e medications, appointments, measuring glucose) for which they want reminders.', test_id: 'C14077' do
      test_rail_expected_steps(4)

      #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users/sessions
      test_rail_expected_result(1, "The mobile user session is created")
      #Super User Session
      super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
      test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
      test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
      #Mobile User Session
      mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
      test_rail_result(1, "mobile_user_session header: #{mobile_user_session.response.headers}")
      test_rail_result(1, "mobile_user_session body: #{mobile_user_session.response.body}")
      mobile_user_id = mobile_user_session.mobile_user_id
      resp_code = mobile_user_session.response.code
      expect(resp_code).to eq 200
      test_rail_result(1, "creating mobile user session response code: #{resp_code}", "pass")

      #Step2 The user makes a Post request on {{protocol}{{url}}/v3/reminder/events
      test_rail_expected_result(2, "The response has a 200 OK status.")
      #Post request on {{protocol}{{url}}/v3/reminder/events
      rule_id = V3::Reminder::Rule::Create.new(super_user_session.token, user_email, base_url, link).id
      reminder_event_create = V3::Reminder::Event::Create.new(super_user_session.token, user_email, base_url, rule_id, mobile_user_id)
      resp_code = reminder_event_create.response.code
      resp_json = JSON.parse(reminder_event_create.response.body)
      test_rail_result(2, "reminder_event_create header: #{reminder_event_create.response.headers}")
      test_rail_result(2, "reminder_event_create body: #{reminder_event_create.response.body}")
      expect(resp_code).to eq 201
      test_rail_result(2, "creating reminder event response code: #{resp_code}", "pass")
      event_id = resp_json.dig('data', 'id')

      #Step3 The unauthorized user makes a Post request on {{protocol}{{url}}/v3/reminder/events
      test_rail_expected_result(3, "The response has 403 Unauthorized status")
      #Unauthorized User Session
      unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
      test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
      test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
      #Post request on {{protocol}{{url}}/v3/reminder/events
      reminder_event_create = V3::Reminder::Event::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, rule_id, mobile_user_id)
      resp_code = reminder_event_create.response.code
      test_rail_result(3, "reminder_event_create header: #{reminder_event_create.response.headers}")
      test_rail_result(3, "reminder_event_create body: #{reminder_event_create.response.body}")
      expect(resp_code).to eq 403
      test_rail_result(3, "creating reminder event response code: #{resp_code}", "pass")

      #Step4 The user makes a Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/reminder_events
      test_rail_expected_result(4, "The response body includes the new reminder event.")
      #Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/reminder_events
      mobileuser_reminder_event_index = V3::MobileUser::Reminders::Events::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
      resp_code = mobileuser_reminder_event_index.response.code
      resp_json = JSON.parse(mobileuser_reminder_event_index.response.body)
      test_rail_result(4, "mobileuser_reminder_event_index header: #{mobileuser_reminder_event_index.response.headers}")
      test_rail_result(4, "mobileuser_reminder_event_index body: #{mobileuser_reminder_event_index.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(4, "mobile user reminder event index response code: #{resp_code}", "pass")
      event = resp_json['data'].any? { |data| data.dig('id') == "#{event_id}"}
      expect(event).to be true
      test_rail_result(4, "mobile user new reminder event in response: #{event}", "pass")
  end

end

