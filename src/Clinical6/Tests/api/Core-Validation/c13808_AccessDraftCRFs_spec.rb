require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "datacollection_capturedvaluegroups_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C13808 Allows user to access draft CRFs from the CRF collection tables', test_id: 'C13808' do
    test_rail_expected_steps(1)

    #Step1 The user makes a GET request on /v3/data_collection/captured_value_groups
    test_rail_expected_result(1, "All captured value groups data are displayed including final submission")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #GET request on /v3/data_collection/captured_value_groups
    datacollection_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    resp_code = datacollection_capturedvaluegroups.response.code
    resp_json = JSON.parse(datacollection_capturedvaluegroups.response.body)
    test_rail_result(1, "datacollection_capturedvaluegroups header: #{datacollection_capturedvaluegroups.response.headers}")
    test_rail_result(1, "datacollection_capturedvaluegroups body: #{datacollection_capturedvaluegroups.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting data collection captured value groups response code: #{resp_code}", "pass")
    status = resp_json['data'].all? { |data| data.dig('attributes', 'final_submission') == "true"||"false"}
    expect(status).to be true
    test_rail_result(1, "final_submission of data collection captured value groups in response is true or false: #{status}", "pass")
  end

end

