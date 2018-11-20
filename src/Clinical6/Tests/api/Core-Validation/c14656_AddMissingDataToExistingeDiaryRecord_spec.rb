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
  let(:text) { Time.new.strftime("%Y%m%d") }


  it 'C14656 The system shall support the ability to add missing eDiary data to an existing eDiary record.', test_id: 'C14656' do
    test_rail_expected_steps(5)

    #Step1 Make a Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/data_collection/captured_value_groups
    test_rail_expected_result(1, "All captured value groups(entries) for that user are displayed in the response")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(1, "mobile_user_session header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "mobile_user_session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #Get request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/data_collection/captured_value_groups
    mobileuser_datacollection_capturedvaluegroups = V3::MobileUser::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_datacollection_capturedvaluegroups.response.code
    test_rail_result(1, "mobileuser_datacollection_capturedvaluegroups header: #{mobileuser_datacollection_capturedvaluegroups.response.headers}")
    test_rail_result(1, "mobileuser_datacollection_capturedvaluegroups body: #{mobileuser_datacollection_capturedvaluegroups.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting mobile user data collection captured value groups response code: #{resp_code}", "pass")

    #Step2 Make a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    test_rail_expected_result(2, "The user receives a 200 OK with the updated information under the same captured_value_group_id")
    #Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    datacollection_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    group_id = datacollection_capturedvaluegroups.id[:group]
    flow_id = datacollection_capturedvaluegroups.id[:flow_process]
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(super_user_session.token, user_email, base_url, flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response.code
    test_rail_result(2, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(2, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "creating data collection flow process values response code: #{resp_code}", "pass")

    #Step3 Make a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values with invalid id
    test_rail_expected_result(3, "The user receives a 422 Unprocessable entity status")
    #Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    invalid_flow_id = test_data["invalid_id"]
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(super_user_session.token, user_email, base_url, invalid_flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response.code
    test_rail_result(3, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(3, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(3, "creating data collection flow process values with invalid id response code: #{resp_code}", "pass")

    #Step4 Make a Delete request on {{protocol}}{{url}} /v3/users/sessions
    test_rail_expected_result(4, "The user receives 204 status and the session is deleted")
    #Delete request on {{protocol}}{{url}} /v3/users/sessions
    token = super_user_session.token
    delete_session = V3::Users::Session::Delete.new(token, user_email, base_url)
    resp_code = delete_session.response.code
    test_rail_result(4, "delete_session header: #{delete_session.response.headers}")
    test_rail_result(4, "delete_session body: #{delete_session.response.body}")
    expect(resp_code).to eq 204
    test_rail_result(4, "deleting user session response code: #{resp_code}", "pass")

    #Step5 Make a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    test_rail_expected_result(5, "The user receives a 401 Unauthorized status")
    #Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(token, user_email, base_url, flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response.code
    test_rail_result(5, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(5, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 401
    test_rail_result(5, "creating data collection flow process values response code: #{resp_code}", "pass")
  end

end

