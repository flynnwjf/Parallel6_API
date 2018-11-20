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
  let(:testname) { "navigation_actiondetails_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C12991 Admin User should be able to retrieve the list of possible action details that can be attached to an AppMenu', test_id: 'C12991' do
    test_rail_expected_steps(2)

    #Step1 The user makes a GET request on {{protocol}}{{url}}/v3/navigation/action_details
    test_rail_expected_result(1, "User receives a 200 OK response and the list of all available action types.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #GET /v3/navigation/action_details
    action_details = V3::Navigation::ActionDetails::Index.new(super_user_session.token, user_email, base_url)
    resp_code = action_details.response.code
    test_rail_result(1, "action_details header: #{action_details.response.headers}")
    test_rail_result(1, "action_details body: #{action_details.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "retrieving action details response code: #{resp_code}", "pass")
    resp_json = JSON.parse(action_details.response.body)
    id = resp_json['data'].all? { |detail| detail.dig('id') != nil }
    type = resp_json['data'].all? { |detail| detail.dig('type').class == String }
    expect(id).to be true
    expect(type).to be true
    test_rail_result(1, "id(s) contained in response: #{id}", "pass")
    test_rail_result(1, "type(s) contained in response: #{type}", "pass")

    #Step2 The unauthorized user makes a Get request on {{protocol}}{{url}}/v3/navigation/action_details
    test_rail_expected_result(2, "User receives a 403 forbidden response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(2, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(2, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #GET /v3/navigation/action_details
    action_details = V3::Navigation::ActionDetails::Index.new(unauthorized_user_session.token, unauthorized_user_email, base_url)
    resp_code = action_details.response.code
    test_rail_result(2, "action_details header: #{action_details.response.headers}")
    test_rail_result(2, "action_details body: #{action_details.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(2, "retrieving action details response code: #{resp_code}", "pass")
  end

end

