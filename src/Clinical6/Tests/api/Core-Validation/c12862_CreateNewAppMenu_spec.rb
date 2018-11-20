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
  let(:testname) { "navigation_appmenus_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:title) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C12862 Admin User should be able to create new app menus', test_id: 'C12862' do
    test_rail_expected_steps(3)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/navigation/app_menus
    test_rail_expected_result(1, "It returns a 201 response and the app menu is created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/navigation/app_menus
    flow_process_id = V3::DataCollection::FlowProcesses::Index.new(super_user_session.token, user_email, base_url).id
    app_menus = V3::Navigation::AppMenus::Create.new(super_user_session.token, user_email, base_url, flow_process_id, title)
    resp_code = app_menus.response.code
    resp_json = JSON.parse(app_menus.response.body)
    test_rail_result(1, "app_menus header: #{app_menus.response.headers}")
    test_rail_result(1, "app_menus body: #{app_menus.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating app menus response code: #{resp_code}", "pass")
    app_menus_id = resp_json.dig('data', 'id')
    expect(app_menus_id).not_to eq nil
    test_rail_result(1, "created app menu id in response: #{app_menus_id}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/navigation/app_menus with invalid parameters
    test_rail_expected_result(2, "It returns a 422 Unprocessable Entity and the app menu is not created")
    #POST request on {{protocol}}{{url}}/v3/navigation/app_menus with invalid parameters
    flow_process_id = test_data["invalid_id"]
    app_menus = V3::Navigation::AppMenus::Create.new(super_user_session.token, user_email, base_url, flow_process_id, title)
    resp_code = app_menus.response.code
    test_rail_result(2, "app_menus header: #{app_menus.response.headers}")
    test_rail_result(2, "app_menus body: #{app_menus.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating app menu with invalid parameters response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a post request on {{protocol}}{{url}}/v3/navigation/app_menus
    test_rail_expected_result(3, "It returns a 403 Forbidden and the app menu is not created")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/navigation/app_menus
    flow_process_id = V3::DataCollection::FlowProcesses::Index.new(super_user_session.token, user_email, base_url).id
    app_menus = V3::Navigation::AppMenus::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, flow_process_id, title)
    resp_code = app_menus.response.code
    test_rail_result(3, "app_menus header: #{app_menus.response.headers}")
    test_rail_result(3, "app_menus body: #{app_menus.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "creating app menu response code: #{resp_code}", "pass")
  end

end

