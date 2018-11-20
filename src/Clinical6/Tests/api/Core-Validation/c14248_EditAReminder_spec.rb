require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_email) { mobile_user["email"] }
  let(:mobile_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
#Test Info
  let(:testname) { "mobileuser_reminder_event_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:title) { "Test" + Time.new.strftime("%Y%m%d").to_s }
  let(:rule_id) { test_data["rule_id"] }


  it 'C14248 System allows to edit a reminder', test_id: 'C14248' do
    test_rail_expected_steps(3)

    #Step1 The user makes a Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/reminder_events
    test_rail_expected_result(1, "The reminder event details along with the relationship with the user is displayed in the response")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/reminder_events
    mobileuser_reminder_event = V3::MobileUser::Reminders::Events::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    event_id = mobileuser_reminder_event.id
    resp_code = mobileuser_reminder_event.response.code
    test_rail_result(1, "mobileuser_reminder_event header: #{mobileuser_reminder_event.response.headers}")
    test_rail_result(1, "mobileuser_reminder_event body: #{mobileuser_reminder_event.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting mobile user reminder events response code: #{resp_code}", "pass")

    #Step2 The user makes a Patch request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/reminder_events/reminder_event_id
    test_rail_expected_result(2, "User receives 200 OK all ediary entries recorded by {{mobile_user_id}}are displayed on the response")
    #Patch request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/reminder_events/reminder_event_id
    mobileuser_reminder_event_update = V3::MobileUser::Reminders::Events::Update.new(super_user_session.token, user_email, base_url, event_id, title, mobile_user_id, rule_id)
    resp_code = mobileuser_reminder_event_update.response.code
    resp_json = JSON.parse(mobileuser_reminder_event_update.response.body)
    test_rail_result(2, "mobileuser_reminder_event_update header: #{mobileuser_reminder_event_update.response.headers}")
    test_rail_result(2, "mobileuser_reminder_event_update body: #{mobileuser_reminder_event_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "updating mobile user reminder event response code: #{resp_code}", "pass")
    expect(resp_json.dig('data','attributes','extras','title')).to eq title
    test_rail_result(2, "updated title of mobile user reminder event in response: #{title}", "pass")

    #Step3 The user makes a Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/reminder_events
    test_rail_expected_result(3, "The response with the edited fields updated is displayed")
    #Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/reminder_events
    mobileuser_reminder_event = V3::MobileUser::Reminders::Events::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_reminder_event.response.code
    resp_json = JSON.parse(mobileuser_reminder_event.response.body)
    test_rail_result(3, "mobileuser_reminder_event header: #{mobileuser_reminder_event.response.headers}")
    test_rail_result(3, "mobileuser_reminder_event body: #{mobileuser_reminder_event.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting mobile user reminder events response code: #{resp_code}", "pass")
    value = resp_json['data'].any? { |data| data.dig('attributes','extras', 'title') == "#{title}"}
    expect(value).to be true
    test_rail_result(3, "updated title of mobile user reminder event in response: #{value}", "pass")
  end

end

