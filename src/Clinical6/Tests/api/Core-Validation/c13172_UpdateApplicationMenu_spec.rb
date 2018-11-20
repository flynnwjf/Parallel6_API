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
  let(:testname) { "navigation_appmenus_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:title) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:update_title) { "UpdateTest" + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C13172 Admin User should be able to update an Application Menu', test_id: 'C13172' do
    test_rail_expected_steps(4)

    #Step1 The user makes a PATCH request on {{protocol}}{{url}}/v3/navigation/app_menus/:id
    test_rail_expected_result(1, "The user receives a 200 response and the menu is updated.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #PATCH request on {{protocol}}{{url}}/v3/navigation/app_menus/:id
    flow_process_id = V3::DataCollection::FlowProcesses::Index.new(super_user_session.token, user_email, base_url).id
    app_menu_id = V3::Navigation::AppMenus::Create.new(super_user_session.token, user_email, base_url, flow_process_id, title).id
    app_menus_update = V3::Navigation::AppMenus::Update.new(super_user_session.token, user_email, base_url, app_menu_id, update_title)
    resp_code = app_menus_update.response.code
    resp_json = JSON.parse(app_menus_update.response.body)
    test_rail_result(1, "app_menus_update header: #{app_menus_update.response.headers}")
    test_rail_result(1, "app_menus_update body: #{app_menus_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "app_menus_update response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'id')).to eq app_menu_id
    expect(resp_json.dig("data", "attributes", "title")).to eq update_title
    test_rail_result(1, "updated title for app menu in response: #{update_title}", "pass")

    #Step2 The user makes a PATCH request on {{protocol}}{{url}}/v3/navigation/app_menus/:id with invalid parameter
    test_rail_expected_result(2, "The user receives a 422 response and the menu is not updated.")
    #PATCH request on {{protocol}}{{url}}/v3/navigation/app_menus/:id
    app_menus_update = V3::Navigation::AppMenus::Update.new(super_user_session.token, user_email, base_url, app_menu_id, "")
    resp_code = app_menus_update.response.code
    test_rail_result(2, "app_menus_update header: #{app_menus_update.response.headers}")
    test_rail_result(2, "app_menus_update body: #{app_menus_update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "app_menus_update response code: #{resp_code}", "pass")

    #Step3 The user makes a PATCH request on {{protocol}}{{url}}/v3/navigation/app_menus/:id with invalid id
    test_rail_expected_result(3, "The user receives a 404 response and no data is returned.")
    #PATCH request on {{protocol}}{{url}}/v3/navigation/app_menus/:id
    invalid_id = test_data["invalid_id"]
    app_menus_update = V3::Navigation::AppMenus::Update.new(super_user_session.token, user_email, base_url, invalid_id, update_title)
    resp_code = app_menus_update.response.code
    test_rail_result(3, "app_menus_update header: #{app_menus_update.response.headers}")
    test_rail_result(3, "app_menus_update body: #{app_menus_update.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(3, "app_menus_update response code: #{resp_code}", "pass")

    #Step4 The unauthorized user makes a PATCH request on {{protocol}}{{url}}/v3/navigation/app_menus/:id
    test_rail_expected_result(4, "The user receives a 403 forbidden response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #PATCH request on {{protocol}}{{url}}/v3/navigation/app_menus/:id
    app_menus_update = V3::Navigation::AppMenus::Update.new(unauthorized_user_session.token, unauthorized_user_email, base_url, app_menu_id, update_title)
    resp_code = app_menus_update.response.code
    test_rail_result(4, "app_menus_update header: #{app_menus_update.response.headers}")
    test_rail_result(4, "app_menus_update body: #{app_menus_update.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(4, "app_menus_update response code: #{resp_code}", "pass")
  end

end

