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


  it 'C13746 User can mark an alert as read', test_id: 'C13746' do
    test_rail_expected_steps(3)

    #Step1 The user makes a GET request on /v3/:resource/:resource_id/notifications/deliveries
    test_rail_expected_result(1, "Look at the last entry and capture the id")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #GET request on /v3/:resource/:resource_id/notifications/deliveries
    mobileuser_notifications_deliveries = V3::MobileUser::Notifications::Deliveries::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_notifications_deliveries.response.code
    test_rail_result(1, "mobileuser_notifications_deliveries header: #{mobileuser_notifications_deliveries.response.headers}")
    test_rail_result(1, "mobileuser_notifications_deliveries body: #{mobileuser_notifications_deliveries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "showing mobile user notifications deliveries response code: #{resp_code}", "pass")
    id = mobileuser_notifications_deliveries.id
    test_rail_result(1, "last one of notifications deliveries in response is: #{id}", "pass")

    #Step2 The user makes a Patch request on /v3/:resource/:resource_id/notifications/deliveries/:id
    test_rail_expected_result(2, "The notification has been updated")
    #Patch request on /v3/:resource/:resource_id/notifications/deliveries/:id
    status = "completed"
    update_mobileuser_notifications_deliveries = V3::MobileUser::Notifications::Deliveries::Update.new(super_user_session.token, user_email, base_url, id, mobile_user_id, status)
    resp_code = update_mobileuser_notifications_deliveries.response.code
    resp_json = JSON.parse(update_mobileuser_notifications_deliveries.response.body)
    test_rail_result(2, "update_mobileuser_notifications_deliveries header: #{update_mobileuser_notifications_deliveries.response.headers}")
    test_rail_result(2, "update_mobileuser_notifications_deliveries body: #{update_mobileuser_notifications_deliveries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "updating mobile user notifications deliveries response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'status')).to eq status
    test_rail_result(2, "updated status in response: #{status}", "pass")
    sleep(60)

    #Step3 The user makes a GET request on /v3/:resource/:resource_id/notifications/deliveries
    test_rail_expected_result(3, "Look at the entry updated in step 2 and the values are updated")
    #GET request on /v3/:resource/:resource_id/notifications/deliveries
    mobileuser_notifications_deliveries = V3::MobileUser::Notifications::Deliveries::Show.new(super_user_session.token, user_email, base_url, id, mobile_user_id)
    resp_code = mobileuser_notifications_deliveries.response.code
    resp_json = JSON.parse(mobileuser_notifications_deliveries.response.body)
    test_rail_result(3, "mobileuser_notifications_deliveries header: #{mobileuser_notifications_deliveries.response.headers}")
    test_rail_result(3, "mobileuser_notifications_deliveries body: #{mobileuser_notifications_deliveries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "showing mobile user notifications deliveries response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'status')).to eq status
    test_rail_result(3, "the entry updated in step 2 is shown and the values are updated", "pass")
  end

end

