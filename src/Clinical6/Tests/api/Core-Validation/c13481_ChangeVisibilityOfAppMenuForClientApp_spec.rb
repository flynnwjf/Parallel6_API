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

  it 'C13481 API Client should be able to enable or disable an AppMenu, so that he can change the visibility of the AppMenu for the Client Applications', test_id: 'C13481' do
    test_rail_expected_steps(5)
    #Step1 Create an AppMenu with endpoint /v3/navigation/app_menus.
    test_rail_expected_result(1, "201 response and newly created menu id.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")

    created_menu = V3::Navigation::AppMenus::Create.new(super_user_session.token, user_email, base_url, '1', 'SEC')
    test_rail_result(1, "created_menu header: #{created_menu.response.headers}")
    test_rail_result(1, "created_menu body: #{created_menu.response.body}")

    expect(created_menu.response.code).to eq 201
    test_rail_result(1, "created_menu response code: #{created_menu.response.code}")

    expect(created_menu.id).not_to be nil
    test_rail_result(1, "created_menu id: #{created_menu.id}", "pass")

    #Replace {{id}} with the actual value of an existing parent application menu with a submenu.
    test_rail_expected_result(2, "200 response and enabled is false by default.")
    replace_menu = V3::Navigation::AppMenus::Update.new(super_user_session.token, user_email, base_url, created_menu.id, created_menu.id, false)
    test_rail_result(2, "replace_menu header: #{replace_menu.response.headers}")
    test_rail_result(2, "replace_menu body: #{replace_menu.response.body}")

    expect(replace_menu.enabled).to be false
    test_rail_result(2, "replace_menu enabled: #{replace_menu.enabled}")

    expect(replace_menu.response.code).to eq 200
    test_rail_result(2, "replace_menu response code: #{replace_menu.response.code}", "pass")

    #Replace {{id}} with an invalid ID and click Send.
    test_rail_expected_result(3, "Null AppMenu ID Returns a 404")
    null_id = nil
    null_menuid = V3::Navigation::AppMenus::Update.new(super_user_session.token, user_email, base_url, null_id, null_id, false)
    test_rail_result(3, "null_menuid header: #{null_menuid.response.headers}")
    test_rail_result(3, "null_menuid body: #{null_menuid.response.body}")

    expect(null_menuid.response.code).to eq 404
    test_rail_result(3, "null_menuid response code: #{null_menuid.response.code}")

    test_rail_expected_result(3, "Invalid AppMenu ID Returns a 404 response")
    invalid_id = -1423
    invalid_menuid = V3::Navigation::AppMenus::Update.new(super_user_session.token, user_email, base_url, invalid_id, invalid_id, false)
    test_rail_result(3, "invalid_menuid header: #{invalid_menuid.response.headers}")
    test_rail_result(3, "invalid_menuid body: #{invalid_menuid.response.body}")

    expect(invalid_menuid.response.code).to eq 404
    test_rail_result(3, "invalid_menuid response code: #{invalid_menuid.response.code}", "pass")

    #Replace {{id}} with the actual value of an existing parent application menu with a submenu.
    test_rail_expected_result(4, "201 response and enabled is set to true.")
    menu_is_enabled = V3::Navigation::AppMenus::Update.new(super_user_session.token, user_email, base_url, created_menu.id, created_menu.id, true)
    test_rail_result(4, "menu_is_enabled header: #{menu_is_enabled.response.headers}")
    test_rail_result(4, "menu_is_enabled body: #{menu_is_enabled.response.body}")

    expect(menu_is_enabled.enabled).to be true
    test_rail_result(4, "menu_is_enabled enabled: #{menu_is_enabled.enabled}")

    expect(replace_menu.response.code).to eq 200
    test_rail_result(4, "replace_menu response code: #{replace_menu.response.code}", "pass")

    #Delete Created AppMenu
    test_rail_expected_result(5, "App menu delete returns 204.")
    deleted_menu = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, created_menu.id)
    test_rail_result(5, "deleted_menu header: #{deleted_menu.response.headers}")
    test_rail_result(5, "deleted_menu body: #{deleted_menu.response.body}")

    expect(deleted_menu.response.code).to eq 204
    test_rail_result(5, "deleted_menu response code: #{deleted_menu.response.code}", "pass")

  end

end

