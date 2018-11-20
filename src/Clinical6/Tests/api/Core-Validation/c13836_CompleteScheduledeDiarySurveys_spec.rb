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


  it 'C13836 Allows user to complete scheduled eDiary surveys', test_id: 'C13836' do
    test_rail_expected_steps(4)

    #Step1 Make a Post request on /v3/mobile_users/sessions
    test_rail_expected_result(1, "User can get mobile user id")
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
    test_rail_result(1, "creating mobile_user_session response code: #{resp_code}", "pass")

    #Step2 Make a Post request on /v3/ediary/entry_groups
    test_rail_expected_result(2, "User can get entry_group_id")
    #Post request on /v3/ediary/entry_groups
    entry_groups = V3::Ediary::Entries::Create.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = entry_groups.response.code
    resp_json = JSON.parse(entry_groups.response.body)
    test_rail_result(2, "entry_groups header: #{entry_groups.response.headers}")
    test_rail_result(2, "entry_groups body: #{entry_groups.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "creating entry_groups response code: #{resp_code}", "pass")
    entry_id = entry_groups.id
    entry_group_id = entry_groups.group_id

    #Step3 Make a Get request on /v3/mobile_users/{{mobile_user_id}}/ediary/entries?filters[entry_group_id]=2&filters[date]=xxxx-xx-xx
    test_rail_expected_result(3, "User can get 200 response and the ediary entries scheduled for the date mentioned are displayed in the response.")
    #Get request on /v3/mobile_users/{{mobile_user_id}}/ediary/entries?filters[entry_group_id]=2&filters[date]=xxxx-xx-xx
    entry_mobile_user = V3::MobileUser::Ediary::Entries::Show.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = entry_mobile_user.response.code
    resp_json = JSON.parse(entry_mobile_user.response.body)
    test_rail_result(3, "entry_mobile_user header: #{entry_mobile_user.response.headers}")
    test_rail_result(3, "entry_mobile_user body: #{entry_mobile_user.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting entry for mobile user response code: #{resp_code}", "pass")
    match_1 = resp_json['data'].any? {|data| data.dig('id') == "#{entry_id}"}
    match_2 = resp_json['data'].any? {|data| data.dig('relationships', 'entry_group', 'data', 'id') == "#{entry_group_id}"}
    expect(match_1).to be true
    expect(match_2).to be true
    test_rail_result(3, "entry id in response: #{match_1}", "pass")
    test_rail_result(3, "entry group id in response: #{match_2}", "pass")

    #Step4 Make a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    test_rail_expected_result(4, "User can get 200 response and the ediary entry of a specific date is captured and saved")
    #Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    datacollection_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    group_id = datacollection_capturedvaluegroups.id[:group]
    flow_id = datacollection_capturedvaluegroups.id[:flow_process]
    text = "2018-09-09T00:00:00Z"
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(super_user_session.token, user_email, base_url, flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response.code
    test_rail_result(4, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(4, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(4, "creating data collection flow process values response code: #{resp_code}", "pass")
  end

end

