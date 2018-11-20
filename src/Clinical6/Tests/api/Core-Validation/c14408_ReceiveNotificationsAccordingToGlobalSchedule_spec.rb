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


  it 'C14408 The system should allow user to receive custom notifications according to a global schedule.', test_id: 'C14408' do
    test_rail_expected_steps(3)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users/sessions
    test_rail_expected_result(1, "The mobile user session id created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    resp_code = mobile_user_session.response.code
    expect(resp_code).to eq 200
    test_rail_result(1, "creating mobile user session response code: #{resp_code}", "pass")

    #Step2 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/scheduler/personalized_rule_schedules
    test_rail_expected_result(2, "The personalized schedule should be enabled")
    #Post request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/scheduler/personalized_rule_schedules
    rule_id = V3::Reminder::Rule::Index.new(super_user_session.token, user_email, base_url).id
    personalized_rule_schedules = V3::MobileUser::Scheduler::PersonalizedRuleSchedules::Create.new(super_user_session.token, user_email, base_url, mobile_user_id, rule_id)
    resp_code = personalized_rule_schedules.response.code
    resp_json = JSON.parse(personalized_rule_schedules.response.body)
    test_rail_result(2, "personalized_rule_schedules header: #{personalized_rule_schedules.response.headers}")
    test_rail_result(2, "personalized_rule_schedules body: #{personalized_rule_schedules.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "creating personalized rule schedules response code: #{resp_code}", "pass")
    expect(resp_json.dig('data','attributes','enabled')).to eq true
    test_rail_result(2, "The personalized schedule is enabled in response", "pass")

    #Step3 The user makes a Get request on {{protocol}}{{url}}/v3/mobile_users{{mobile_user_id}}/notifications/deliveries
    test_rail_expected_result(3, "The user is able to view the notification delivery and observe the time of the delivery, The user should receive notification adjusted to the time-zone")
    #Get request on {{protocol}}{{url}}/v3/mobile_users{{mobile_user_id}}/notifications/deliveries
    mobileuser_notifications_deliveries = V3::MobileUser::Notifications::Deliveries::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_notifications_deliveries.response.code
    resp_json = JSON.parse(mobileuser_notifications_deliveries.response.body)
    test_rail_result(3, "mobileuser_notifications_deliveries header: #{mobileuser_notifications_deliveries.response.headers}")
    test_rail_result(3, "mobileuser_notifications_deliveries body: #{mobileuser_notifications_deliveries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting mobile user notifications deliveries response code: #{resp_code}", "pass")
    time = resp_json['data'].any? { |data| data.dig('attributes','opts', 'triggerer', 'timezone') == "UTC"}
    expect(time).to be true
    test_rail_result(3, "receive notification adjusted to the time-zone in response: #{time}", "pass")
  end

end

