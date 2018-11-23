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


  it 'C13801 Allows user to see if the status of an eCOA survey is incomplete, complete, change required, in progress', test_id: 'C13801' do
    test_rail_expected_steps(1)

    #Step1 Make a POST request on /v3/status_check
    test_rail_expected_result(1, "The user receives 201 OK status and the status is shown")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    #POST request on /v3/status_check
    type = "DataCollection::CapturedValueGroups"
    status_check = V3::StatusCheck::Create.new(super_user_session.token, user_email, base_url, type)
    resp_code = status_check.response.code
    resp_json = JSON.parse(status_check.response.body)
    status = resp_json.dig('data','attributes', 'value').to_s
    test_rail_result(1, "status_check header: #{status_check.response.headers}")
    test_rail_result(1, "status_check body: #{status_check.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "status check response code: #{resp_code}", "pass")
    match = ["incomplete","completed","in progress", "change required"].include? status
    expect(match).to be true
    test_rail_result(1, "status in response is: #{status}", "pass")
  end

end

