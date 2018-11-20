require_relative '../../../../../src/spec_helper'
require_relative '../../../../../src/Clinical6/PageFunctions/api/v3/navigation/appmenus/helpers'

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

  it 'C13019 API Client should be able to enable or disable an AppMenu, so that he can change the visibility of the AppMenu for the Client Applications', test_id: 'C13019' do
    test_rail_expected_steps(13)

    #Step1 Create an AppMenu 1 with endpoint /v3/navigation/app_menus.
    step = 1
    test_rail_expected_result(step, "201 response and newly created menu id.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(step, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(step, "Super User session body: #{super_user_session.response.body}")

    V3::Navigation::AppMenu::MenuHelper.new(super_user_session.token, user_email, base_url)
        .delete_all_menus("true")

    created_menu1 = V3::Navigation::AppMenus::Create.new(super_user_session.token, user_email, base_url, '1', 'ParentMenu1')
    test_rail_result(step, "created_menu1 header: #{created_menu1.response.headers}")
    test_rail_result(step, "created_menu1 body: #{created_menu1.response.body}")

    expect(created_menu1.response.code).to eq 201
    test_rail_result(step, "created_menu1 response code: #{created_menu1.response.code}")

    expect(created_menu1.id).not_to be nil
    test_rail_result(step, "created_menu1 id: #{created_menu1.id}", "pass")

    #Step2 Create an AppMenu 2 with endpoint /v3/navigation/app_menus.
    step = 2
    test_rail_expected_result(step, "201 response and newly created menu id.")
    created_menu2 = V3::Navigation::AppMenus::Create.new(super_user_session.token, user_email, base_url, '1', 'ParentMenu2')
    test_rail_result(step, "created_menu2 header: #{created_menu2.response.headers}")
    test_rail_result(step, "created_menu2 body: #{created_menu2.response.body}")

    expect(created_menu2.response.code).to eq 201
    test_rail_result(step, "created_menu2 response code: #{created_menu2.response.code}")

    expect(created_menu2.id).not_to be nil
    test_rail_result(step, "created_menu2 id: #{created_menu2.id}", "pass")

    #Step3 Create an SubAppMenu 1 with endpoint /v3/navigation/app_menus.
    step = 3
    test_rail_expected_result(step, "201 response and newly created menu id.")

    created_submenu1 = V3::Navigation::AppMenus::SubMenus::Create.new(super_user_session.token, user_email, base_url, '1', 'SubMenu1', parent_id = created_menu1.id)
    test_rail_result(step, "created_submenu1 header: #{created_submenu1.response.headers}")
    test_rail_result(step, "created_submenu1 body: #{created_submenu1.response.body}")

    expect(created_submenu1.response.code).to eq 201
    test_rail_result(step, "created_submenu1 response code: #{created_submenu1.response.code}")

    expect(created_submenu1.id).not_to be nil
    test_rail_result(step, "created_submenu1 id: #{created_submenu1.id}", "pass")

    # Step4 Attempt to delete created_menu2 with no valid authentication token
    # Expect 401 status response with "Authentication Failed" type error message
    step = 4
    test_rail_expected_result(step, "401 status response with \"Authentication Failed\" type error message from invalid token")
    invalid_token = "invalid"
    invalid_token_res = V3::Navigation::AppMenus::SubMenus::Create.new(invalid_token, user_email, base_url, '1', 'SubMenu1', parent_id = created_menu1.id)
    test_rail_result(step, "created_submenu1 header: #{invalid_token_res.response.headers}")
    test_rail_result(step, "created_submenu1 body: #{invalid_token_res.response.body}")

    expect(invalid_token_res.response.code).to eq 401
    test_rail_result(step, "invalid_token_res response code: #{invalid_token_res.response.code}")
    test_rail_result(step, "created_submenu1 id: #{created_submenu1.id}", "pass")

    # Step5 Attempt to delete created_menu2 (no submenu) with cascade="false"
    # Expect 204 status response with no body in response
    step = 5
    test_rail_expected_result(step, "204 status response with no body in response")
    deleted_menu2 = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, created_menu2.id)
    test_rail_result(step, "deleted_menu2 header: #{deleted_menu2.response.headers}")

    expect(deleted_menu2.response.code).to eq 204
    test_rail_result(step, "deleted_menu2 response code: #{deleted_menu2.response.code}", "pass")

    # Step6 Validate created_menu2 is deleted
    # Expect 404 status response with "Record Not Found" type error message
    step = 6
    test_rail_expected_result(step, "404 status response with \"Record Not Found\" type error message")
    validate_menu2_deleted = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, created_menu2.id)
    test_rail_result(step, "validate_menu2_deleted header: #{validate_menu2_deleted.response.headers}")

    expect(validate_menu2_deleted.response.code).to eq 404
    test_rail_result(step, "deleted_menu2 response code: #{validate_menu2_deleted.response.code}", "pass")

    # Step7 (Negative) Attempt to delete menu1 again & verify record not found error message (this menu should not exist since it was already deleted)
    # Expect 404 status response with "Record Not Found" type error message
    step = 7
    test_rail_expected_result(step, "404 status response with \"Record Not Found\" type error message")
    validate_menu2_deleted = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, created_menu2.id)
    test_rail_result(step, "validate_menu2_deleted header: #{validate_menu2_deleted.response.headers}")
    test_rail_result(step, "validate_menu2_deleted body: #{validate_menu2_deleted.response.body}")

    expect(validate_menu2_deleted.response.code).to eq 404
    test_rail_result(step, "deleted_menu2 response code: #{validate_menu2_deleted.response.code}", "pass")

    # Step8 (Negative) Attempt to delete menu2 with cascade flag set to false & verify failed delete
    # Expect 422 status response with "Cannot delete menu that has sub-menus" type error message
    step = 8
    test_rail_expected_result(step, "422 status response with \"Cannot delete menu that has sub-menus\" type error message")
    cannot_delete_menu = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, created_menu1.id)
    test_rail_result(step, "validate_menu2_deleted header: #{cannot_delete_menu.response.headers}")
    test_rail_result(step, "validate_menu2_deleted body: #{cannot_delete_menu.response.body}")

    expect(cannot_delete_menu.response.code).to eq 422
    test_rail_result(step, "deleted_menu2 response code: #{validate_menu2_deleted.response.code}", "pass")

    # Step9 Delete menu2 with cascade flag set to true
    # Expect 204 status response with no body in response
    step = 9
    test_rail_expected_result(step, "204 status response with no body in response")
    cascade_delete_menu = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, created_menu1.id, true)
    test_rail_result(step, "validate_menu2_deleted header: #{cascade_delete_menu.response.headers}")
    test_rail_result(step, "validate_menu2_deleted body: #{cascade_delete_menu.response.body}")

    expect(cascade_delete_menu.response.code).to eq 204
    test_rail_result(step, "deleted_menu2 response code: #{cascade_delete_menu.response.code}", "pass")

    # Step10 Verify <Menu2Id> is deleted
    # Expect 404 status response with "Record Not Found" type error message
    step = 10
    test_rail_expected_result(step, "404 status response with \"Record Not Found\" type error message")

    fail_delete_menu2 = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, created_menu2.id)
    test_rail_result(step, "validate_menu2_deleted header: #{fail_delete_menu2.response.headers}")
    test_rail_result(step, "validate_menu2_deleted body: #{fail_delete_menu2.response.body}")

    expect(fail_delete_menu2.response.code).to eq 404
    test_rail_result(step, "deleted_menu2 response code: #{fail_delete_menu2.response.code}", "pass")

    # Step11 Verify <Menu2Id> is deleted
    # Expect 404 status response with "Record Not Found" type error message
    step = 11
    test_rail_expected_result(step, "404 status response with \"Record Not Found\" type error message")
    fail_delete_submenu = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, created_submenu1.id)
    test_rail_result(step, "validate_menu2_deleted header: #{fail_delete_submenu.response.headers}")
    test_rail_result(step, "validate_menu2_deleted body: #{fail_delete_submenu.response.body}")

    expect(fail_delete_submenu.response.code).to eq 404
    test_rail_result(step, "deleted_menu2 response code: #{fail_delete_submenu.response.code}", "pass")

    # Step12 (Negative) Attempt to delete menu with id 0 & verify failed delete (record not found)
    # Expect 404 status response with "Record Not Found" type error message
    step = 12
    test_rail_expected_result(step, "404 status response with \"Record Not Found\" type error message")
    fail_delete_null_menu = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, 0)
    test_rail_result(step, "validate_menu2_deleted header: #{fail_delete_null_menu.response.headers}")
    test_rail_result(step, "validate_menu2_deleted body: #{fail_delete_null_menu.response.body}")

    expect(fail_delete_null_menu.response.code).to eq 404
    test_rail_result(step, "deleted_menu2 response code: #{fail_delete_null_menu.response.code}", "pass")

    # (Negative) Attempt to delete menu with id 0 & verify failed delete (record not found)
    # Expected 404 status response with "Record Not Found" type error message
    step = 13
    test_rail_expected_result(step, "404 status response with \"Record Not Found\" type error message")
    fail_delete_invalid = V3::Navigation::AppMenus::Delete.new(super_user_session.token, user_email, base_url, 999999999999999999999999999999999999)
    test_rail_result(step, "validate_menu2_deleted header: #{fail_delete_invalid.response.headers}")
    test_rail_result(step, "validate_menu2_deleted body: #{fail_delete_invalid.response.body}")

    expect(fail_delete_invalid.response.code).to eq 404
    test_rail_result(step, "deleted_menu2 response code: #{fail_delete_invalid.response.code}", "pass")
  end

end

