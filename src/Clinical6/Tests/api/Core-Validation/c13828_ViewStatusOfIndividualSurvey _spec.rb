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
  let(:testname) { "entry_group_statuses_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C13828 Allows user to view the status each individual survey according to a certain date', test_id: 'C13828' do
    test_rail_expected_steps(1)

    #Step1 Make a Get request on {{protocol}}{{url}}/v3/mobile_users/{id}/ediary/entry_group_statuses
    test_rail_expected_result(1, "User can get a 200 response and list the entry groups for the specified date, along with the 'status' attribute.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(1, "mobile_user_session header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "mobile_user_session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #POST request on{{protocol}}{{url}}/v3/ediary/entry_group_statuses
    entry_group_statuses = V3::MobileUser::Ediary::GroupStatus::Show.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = entry_group_statuses.response.code
    resp_json = JSON.parse(entry_group_statuses.response.body)
    test_rail_result(1, "entry_group_statuses header: #{entry_group_statuses.response.headers}")
    test_rail_result(1, "entry_group_statuses body: #{entry_group_statuses.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "creating entry group statuses response code: #{resp_code}", "pass")
    status = resp_json['data'].any? {|data|data.dig('attributes', 'status') != nil}
    expect(status).to be true
    test_rail_result(1, "entry group statuses in response: #{status}", "pass")
  end

end

