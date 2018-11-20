require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:testname) { "datacollection_capturedvaluegroups_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C13797 Allows user to view a list of all eCOA surveys completed', test_id: 'C13797' do
    test_rail_expected_steps(2)

    #Step1 Make a Get request on /v3/data_collection/captured_value_groups
    test_rail_expected_result(1, "User can get 200 response and a list of all submitted surveys")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on /v3/data_collection/captured_value_groups
    datacollection_capturedvaluegroups_index = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    test_rail_result(1, "datacollection_capturedvaluegroups_index body header: #{datacollection_capturedvaluegroups_index.response.headers}")
    test_rail_result(1, "datacollection_capturedvaluegroups_index body: #{datacollection_capturedvaluegroups_index.response.body}")
    resp_code = datacollection_capturedvaluegroups_index.response.code
    resp_json = JSON.parse(datacollection_capturedvaluegroups_index.response.body)
    expect(resp_code).to eq 200
    test_rail_result(1, "datacollection_capturedvaluegroups_index response code: #{resp_code}", "pass")
    id = resp_json['data'].all? { |id| id.dig('id') != nil}
    type = resp_json['data'].all? { |type| type.dig('type') == "data_collection__captured_value_groups"}
    expect(id).to be true
    expect(type).to be true
    test_rail_result(1, "captured_value_group id(s) in response: #{id}", "pass")
    test_rail_result(1, "captured_value_group list in response: #{type}", "pass")

    #Step2 The unauthorized user makes a Get request on /v3/data_collection/captured_value_groups
    test_rail_expected_result(2, "It returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(2, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(2, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on /v3/data_collection/captured_value_groups
    datacollection_capturedvaluegroups_index = V3::DataCollection::CapturedValueGroups::Index.new(unauthorized_user_session.token, unauthorized_user_email, base_url)
    test_rail_result(2, "datacollection_capturedvaluegroups_index body header: #{datacollection_capturedvaluegroups_index.response.headers}")
    test_rail_result(2, "datacollection_capturedvaluegroups_index body: #{datacollection_capturedvaluegroups_index.response.body}")
    resp_code = datacollection_capturedvaluegroups_index.response.code
    expect(resp_code).to eq 403
    test_rail_result(2, "datacollection_capturedvaluegroups_index response code: #{resp_code}", "pass")
  end

end


