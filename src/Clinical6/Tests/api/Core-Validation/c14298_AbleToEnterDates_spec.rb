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
#Test Info
  let(:testname) { "datacollection_flowprocessvalues_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C14298 Users should be able to enter dates.', test_id: 'C14298' do
    test_rail_expected_steps(3)

    #Step1 Make a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values with invalid data
    test_rail_expected_result(1, "the user receives a 422 unprocessible entities response")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(1, "mobile_user_session header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "mobile_user_session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    datacollection_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    group_id = datacollection_capturedvaluegroups.id[:group]
    flow_id = datacollection_capturedvaluegroups.id[:flow_process]
    text = ""
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(super_user_session.token, user_email, base_url, flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response.code
    test_rail_result(1, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(1, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(1, "creating data collection flow process values response code: #{resp_code}", "pass")

    #Step2 Make a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    test_rail_expected_result(2, "The user receives a 200 OK response with the data captured and the captured_value_group_id created")
    #Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    text = "2018-06-05"
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(super_user_session.token, user_email, base_url, flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response.code
    test_rail_result(2, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(2, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "creating data collection flow process values response code: #{resp_code}", "pass")

    #Step3 Make a Get request on {{protocol}}{{url}}/v3/data_collection/captured_value_groups
    test_rail_expected_result(3, "The user receives 200 OK and all captured_value_groupsare displayed, observe captured_value_group_id from the previous step, the data created in the previous step is displayed")
    #Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    datacollection_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    resp_code = datacollection_capturedvaluegroups.response.code
    resp_json = JSON.parse(datacollection_capturedvaluegroups.response.body)
    test_rail_result(3, "datacollection_capturedvaluegroups header: #{datacollection_capturedvaluegroups.response.headers}")
    test_rail_result(3, "datacollection_capturedvaluegroups body: #{datacollection_capturedvaluegroups.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting data collection captured value groups response code: #{resp_code}", "pass")
    match = resp_json['data'].any? { |data| data.dig('id') == "#{group_id}"}
    expect(match).to be true
    test_rail_result(3, "captured value group id is in response: #{match}", "pass")
  end

end

