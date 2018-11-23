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


  it 'C14292 Users should be able to receive reminders for eCOA surveys based on triggered events', test_id: 'C14292' do
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

    #Step2 The user makes a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    test_rail_expected_result(2, "The data is captured and entry created with a captured value group assigned")
    #Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    datacollection_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    group_id = datacollection_capturedvaluegroups.id_by_mobile(mobile_user_id)[:group]
    flow_id = datacollection_capturedvaluegroups.id_by_mobile(mobile_user_id)[:flow_process]
    text = "this is to test reminder"
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(super_user_session.token, user_email, base_url, flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response.code
    test_rail_result(2, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(2, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "creating data collection flow process values response code: #{resp_code}", "pass")

    #Step3 The user makes a Get request on {{protocol}}{{url}}/v3/mobile_users{{mobile_user_id}}/notifications/deliveries
    test_rail_expected_result(3, "The last record is notifying new data collection form")
    #Get request on {{protocol}}{{url}}/v3/mobile_users{{mobile_user_id}}/notifications/deliveries
    sleep(5)
    mobileuser_notifications_deliveries = V3::MobileUser::Notifications::Deliveries::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_notifications_deliveries.response.code
    resp_json = JSON.parse(mobileuser_notifications_deliveries.response.body)
    test_rail_result(3, "mobileuser_notifications_deliveries header: #{mobileuser_notifications_deliveries.response.headers}")
    test_rail_result(3, "mobileuser_notifications_deliveries body: #{mobileuser_notifications_deliveries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting mobile user notifications deliveries response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', mobileuser_notifications_deliveries.count-1, 'attributes','opts', 'captured_value_group_id').to_s).to eq group_id
    test_rail_result(3, "the last record is notifying new data collection form in response", "pass")
  end

end

