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
  let(:testname) { "mobileuser_ediary_entries_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C13838 Allows user to see a list of historical surveys', test_id: 'C13838' do
    test_rail_expected_steps(3)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
    test_rail_expected_result(1, "User receives 200 OK and get mobile user id")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
    resp_code = mobile_user_session.response.code
    expect(resp_code).to eq 200
    test_rail_result(1, "creating mobile_user_session response code: #{resp_code}", "pass")
    mobile_user_id = mobile_user_session.mobile_user_id

    #Step2 The user makes a GET request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/ediary/entry_group_statuses
    test_rail_expected_result(2, "User receives 200 OK all ediary entries recorded by {{mobile_user_id}}are displayed on the response")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(2, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(2, "Super User session body: #{super_user_session.response.body}")
    #GET request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/ediary/entry_group_statuses
    mobileuser_ediary_entries = V3::MobileUser::Ediary::Entries::Show.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_ediary_entries.response.code
    test_rail_result(2, "mobileuser_ediary_entries header: #{mobileuser_ediary_entries.response.headers}")
    test_rail_result(2, "mobileuser_ediary_entries body: #{mobileuser_ediary_entries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "showing mobile user ediary entries response code: #{resp_code}", "pass")

    #Step3 The user makes a GET request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/data_collection/captured_value_groups
    test_rail_expected_result(3, "The user is able to view the entry that they desire")
    #GET request on {{protocol}}{{url}}/v3/mobile_users/mobile_user_id/data_collection/captured_value_groups
    mobileuser_datacollection_capturedvaluegroups = V3::MobileUser::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_datacollection_capturedvaluegroups.response.code
    test_rail_result(3, "mobileuser_datacollection_capturedvaluegroups header: #{mobileuser_datacollection_capturedvaluegroups.response.headers}")
    test_rail_result(3, "mobileuser_datacollection_capturedvaluegroups body: #{mobileuser_datacollection_capturedvaluegroups.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "showing mobile user data collection captured value groups response code: #{resp_code}", "pass")
  end

end

