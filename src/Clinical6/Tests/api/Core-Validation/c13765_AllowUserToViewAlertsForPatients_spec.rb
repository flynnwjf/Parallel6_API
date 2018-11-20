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
  let(:testname) { "mobileuser_notifications_deliveries_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C13765 The system should allow admin users to view alerts for all patients', test_id: 'C13765' do
    test_rail_expected_steps(2)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
    test_rail_expected_result(1, "The user can get 200 response and identify mobile user id")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
    resp_code = mobile_user_session.response.code
    expect(resp_code).to eq 200
    test_rail_result(1, "creating mobile_user_session response code: #{resp_code}", "pass")
    mobile_user_id = mobile_user_session.mobile_user_id

    #Step2 The user makes a GET request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/notifications/events
    test_rail_expected_result(2, "The user can get 200 response and retrieve all notification events for the specified resource.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(2, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(2, "Super User session body: #{super_user_session.response.body}")
    #GET request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/notifications/events
    mobileuser_notifications_deliveries = V3::MobileUser::Notifications::Deliveries::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_notifications_deliveries.response.code
    test_rail_result(2, "mobileuser_notifications_deliveries header: #{mobileuser_notifications_deliveries.response.headers}")
    test_rail_result(2, "mobileuser_notifications_deliveries body: #{mobileuser_notifications_deliveries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "showing mobile user notifications events response code: #{resp_code}", "pass")
  end

end

