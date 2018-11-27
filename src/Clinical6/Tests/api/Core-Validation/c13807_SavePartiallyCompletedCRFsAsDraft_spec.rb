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


  it 'C13807 Allows the user to save a partially completed CRFs as a draft', test_id: 'C13807' do
    test_rail_expected_steps(4)

    #Step1 Make a Post request on {{protocol}}{{url}}/v3/data_collection/flow_process_values
    test_rail_expected_result(1, "It returns 200 response and captured_values for a given flow_process is created")
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
    group_id = datacollection_capturedvaluegroups.id_by_mobile(mobile_user_id)[:group]
    flow_id = datacollection_capturedvaluegroups.id_by_mobile(mobile_user_id)[:flow_process]
    text = "Test" + Time.new.strftime("%Y%m%d")
    datacollection_flowprocessvalues_create = V3::DataCollection::FlowProcessValues::Create.new(mobile_user_session.token, user_email, base_url, flow_id, mobile_user_id, group_id, text)
    resp_code = datacollection_flowprocessvalues_create.response_mobile.code
    test_rail_result(1, "datacollection_flowprocessvalues_create header: #{datacollection_flowprocessvalues_create.response.headers}")
    test_rail_result(1, "datacollection_flowprocessvalues_create body: #{datacollection_flowprocessvalues_create.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "creating data collection flow process values response code: #{resp_code}", "pass")

    #Step2 Make a Get request on {{protocol}}{{url}}/v3/data_collection/captured_value_groups
    test_rail_expected_result(2, "It returns 200 response and the new captured_value is listed")
    # Get request {{protocol}}{{url}}/v3/data_collection/captured_value_groups
    datacollection_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    resp_code = datacollection_capturedvaluegroups.response.code
    test_rail_result(2, "datacollection_capturedvaluegroups header: #{datacollection_capturedvaluegroups.response.headers}")
    test_rail_result(2, "datacollection_capturedvaluegroups body: #{datacollection_capturedvaluegroups.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "getting data collection captured value groups response code: #{resp_code}", "pass")

    #Step3 Make a Patch request on {{protocol}}{{url}}/v3/data_collection/captured_value_groups/:captured_value_group_id
    test_rail_expected_result(3, "It returns 200 response and the value is updated")
    # Get request {{protocol}}{{url}}/v3/data_collection/captured_value_groups
    datacollection_capturedvaluegroups_update = V3::DataCollection::CapturedValueGroups::Update.new(super_user_session.token, user_email, base_url, group_id, false)
    resp_code = datacollection_capturedvaluegroups_update.response.code
    resp_json = JSON.parse(datacollection_capturedvaluegroups_update.response.body)
    test_rail_result(3, "datacollection_capturedvaluegroups_update header: #{datacollection_capturedvaluegroups_update.response.headers}")
    test_rail_result(3, "datacollection_capturedvaluegroups_update body: #{datacollection_capturedvaluegroups_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "updating data collection captured value groups response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'final_submission')).to eq false
    test_rail_result(3, "updating final_submission of data collection captured value groups in response", "pass")

    #Step4 Make a Get request on {{protocol}}{{url}}/v3/data_collection/captured_value_groups/:id
    test_rail_expected_result(4, "The captured data is displayed and the user is able to view the updated value")
    # Get request {{protocol}}{{url}}/v3/data_collection/captured_value_groups/:id
    datacollection_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Show.new(super_user_session.token, user_email, base_url, mobile_user_id, group_id)
    resp_code = datacollection_capturedvaluegroups.response.code
    resp_json = JSON.parse(datacollection_capturedvaluegroups.response.body)
    test_rail_result(4, "datacollection_capturedvaluegroups header: #{datacollection_capturedvaluegroups.response.headers}")
    test_rail_result(4, "datacollection_capturedvaluegroups body: #{datacollection_capturedvaluegroups.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(4, "getting data collection captured value groups response code: #{resp_code}", "pass")
    #status = resp_json['data'].any? { |data| data.dig('attributes', 'final_submission') == "false" && data.dig('id') == "#{group_id}" }
    expect(resp_json.dig('data', 'attributes', 'final_submission')).to eq false
    test_rail_result(4, "final_submission of data collection captured value groups in response is false: #{resp_json.dig('data','final_submission')}", "pass")
  end

end

