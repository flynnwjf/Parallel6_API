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
  let(:text) { "You can type anything here to test the free form text" }


  it 'C14296 Users should be able to answer free form text questions.', test_id: 'C14296' do
    test_rail_expected_steps(1)

    #Step1 Make a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    test_rail_expected_result(1, "the user receives a 200, The free form text data is submitted and captured")
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
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(super_user_session.token, user_email, base_url, flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response.code
    resp_json = JSON.parse(datacollection_flowprocessvalues_create.response.body)
    test_rail_result(1, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(1, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "creating data collection flow process values response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', '22')).to eq text
    test_rail_result(1, "user is able to answer free form text questions", "pass")
  end

end

