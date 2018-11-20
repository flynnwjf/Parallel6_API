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


  it 'C13830 The system should allow for saved eDiary answers to be changed if answered incorrectly', test_id: 'C13830' do
    test_rail_expected_steps(3)

    #Step1 Make a GET request on {{protocol}}{{url}}/v3/data_collection/flow_process_values/{ID}
    test_rail_expected_result(1, "response 200, with values for eDiary group")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(1, "mobile_user_session header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "mobile_user_session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #GET request on {{protocol}}{{url}}/v3/data_collection/flow_process_values/{ID}
    datacollection_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    group_id = datacollection_capturedvaluegroups.id[:group]
    flow_id = datacollection_capturedvaluegroups.id[:flow_process]
    datacollection_flowprocessvalues = V3::DataCollection::FlowProcessValues::Show.new(super_user_session.token, user_email, base_url, group_id)
    resp_code = datacollection_flowprocessvalues.response.code
    test_rail_result(1, "datacollection_flowprocessvalues header: #{datacollection_flowprocessvalues.response.headers}")
    test_rail_result(1, "datacollection_flowprocessvalues body: #{datacollection_flowprocessvalues.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting data collection flow process values response code: #{resp_code}", "pass")

    #Step2 Make a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    test_rail_expected_result(2, "eDiary entry is updated")
    #Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    text = "change answer"
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(super_user_session.token, user_email, base_url, flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response.code
    test_rail_result(2, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(2, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "creating data collection flow process values response code: #{resp_code}", "pass")

    #Step3 Make a GET request on {{protocol}}{{url}}/v3/data_collection/flow_process_values/{ID}
    test_rail_expected_result(3, "eDiary update is displayed")
    #GET request on {{protocol}}{{url}}/v3/data_collection/flow_process_values/{ID}
    datacollection_flowprocessvalues = V3::DataCollection::FlowProcessValues::Show.new(super_user_session.token, user_email, base_url, group_id)
    resp_code = datacollection_flowprocessvalues.response.code
    resp_json = JSON.parse(datacollection_flowprocessvalues.response.body)
    test_rail_result(3, "datacollection_flowprocessvalues header: #{datacollection_flowprocessvalues.response.headers}")
    test_rail_result(3, "datacollection_flowprocessvalues body: #{datacollection_flowprocessvalues.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting data collection flow process values response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', '22')).to eq text
    test_rail_result(3, "submitted data is in response: #{text}", "pass")
  end

end

