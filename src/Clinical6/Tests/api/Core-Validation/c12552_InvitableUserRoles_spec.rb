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
  let(:testname) { "userroles_invitableuserroles_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
# let(:invitable_user_roles) { V3::UserRoles::InvitableUserRoles::Index.new(token, user_email, base_url, super_user_role_id) }

  it 'C12552 Verify list of all user roles (including super user and guest user) from Get /v3/user_roles/ web-service', test_id: 'C12552' do
    test_rail_expected_steps(7)

    #Step1 Using <UserSuperUser>  Verify list of all user roles (including super user and guest user) from Get /v3/user_roles/ web-service
    test_rail_expected_result(1, "200 status response with <UserRoleSuperUser> for super user and <UserRoleGuest> for guest User in response body.")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    token = super_user_session.token
    test_rail_result(1, "User Session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "User Session body: #{super_user_session.response.body}")

    user_roles = V3::UserRoles::Index.new(token, user_email, base_url)
    test_rail_result(1, "user_roles body: #{user_roles.response.body}")
    test_rail_result(1, "user_roles header: #{user_roles.response.headers}")
    expect(user_roles.response.code).to eq 200
    test_rail_result(1, "super_user_role_id: #{user_roles.super_user_id}")
    test_rail_result(1, "guest_user_role_id: #{user_roles.guest_user_id}")
    test_rail_result(1, "user_roles status response code: #{user_roles.response.code}", "pass")

    #Step2 Using <UserSuperUser> Verify list of invitable roles for super user from Get /v3/user_roles/<UserRoleSuperUser>/invitable_user_roles web-service
    test_rail_expected_result(2, "200 status response with a list of the user roles that <UserRoleId1> is allowed to invite (Ex: Admin, Guest) in response body.")
    invitable_user_roles = V3::UserRoles::InvitableUserRoles::Index.new(token, user_email, base_url, user_roles.super_user_id)
    test_rail_result(2, "invitable_user_roles header: #{invitable_user_roles.response.headers}")
    test_rail_result(2, "invitable_user_roles body: #{invitable_user_roles.response.body}")
    expect(invitable_user_roles.response.code).to eq 200
    test_rail_result(2, "invitable_user_roles response code: #{invitable_user_roles.response.code}")
    invitable_user_roles_json = JSON.parse(invitable_user_roles.response.body)
    admin_found = invitable_user_roles_json['data'].any? { |inv_role| inv_role.dig('attributes', 'permanent_link') == 'admin' }
    guest_found = invitable_user_roles_json['data'].any? { |inv_role| inv_role.dig('attributes', 'permanent_link') == 'guest' }
    expect(admin_found).to be true
    test_rail_result(2, "invitable_user_roles contains admin: #{admin_found}")
    expect(guest_found).to be true
    test_rail_result(2, "invitable_user_roles contains guest: #{guest_found}", "pass")

    #Step3 Using <UserSuperUser>  Verify empty list of invitable roles for guest user from Get /v3/user_roles/<UserRoleGuest>/invitable_user_roles web-service
    test_rail_expected_result(3, "200 status response with only users allowed to be invited by guests - if any. (no super user)")

    invitable_user_roles = V3::UserRoles::InvitableUserRoles::Index.new(token, user_email, base_url, user_roles.guest_user_id)
    invitable_user_roles_json = JSON.parse(invitable_user_roles.response.body)
    test_rail_result(3, "invitable_user_roles header: #{invitable_user_roles.response.headers}")
    test_rail_result(3, "invitable_user_roles body: #{invitable_user_roles.response.body}")
    expect(invitable_user_roles.response.code).to eq 200
    test_rail_result(3, "invitable_user_roles response code: #{invitable_user_roles.response.code}")
    admin_found = invitable_user_roles_json['data'].any? { |inv_role| inv_role.dig('attributes', 'permanent_link') == 'admin' }
    expect(admin_found).to be false
    test_rail_result(3, "invitable_user_roles contains admin: #{admin_found}", "pass")

    #Step4 Using <UserSuperUser> (Negative) Verify a record not found for non existing user role from Get /v3/user_roles/999999/invitable_user_roles web-service
    test_rail_expected_result(4, "404 status response with 'Record Not Found' type error message")
    non_existing_user_role = 'bad_id'
    invitable_user_roles = V3::UserRoles::InvitableUserRoles::Index.new(token, user_email, base_url, non_existing_user_role)
    test_rail_result(4, "invitable_user_roles header: #{invitable_user_roles.response.headers}")
    test_rail_result(4, "invitable_user_roles body: #{invitable_user_roles.response.body}")
    expect(invitable_user_roles.response.code).to eq 404
    test_rail_result(4, "invitable_user_roles response code: #{invitable_user_roles.response.code}", "pass")

    #Step5 Using <UserSuperUser>  (Negative) Verify a record not found for 0 user role from Get /v3/user_roles/0/invitable_user_roles web-service
    test_rail_expected_result(5, "404 status response with 'Record Not Found' type error message")
    non_existing_user_role = 0
    invitable_user_roles = V3::UserRoles::InvitableUserRoles::Index.new(token, user_email, base_url, non_existing_user_role)
    test_rail_result(5, "invitable_user_roles header: #{invitable_user_roles.response.headers}")
    test_rail_result(5, "invitable_user_roles body: #{invitable_user_roles.response.body}")
    expect(invitable_user_roles.response.code).to eq 404
    test_rail_result(5, "invitable_user_roles response code: #{invitable_user_roles.response.code}", "pass")

    #Step6 Using <UserSuperUser> (Negative) Verify a record not found for large number user role (Ex: 99999999999999999...9)
    #      from Get /v3/user_roles/99999999999999999999999999999999999999999999999999/invitable_user_roles web-service
    test_rail_expected_result(6, "404 status response with 'Record Not Found' type error message")
    non_existing_user_role = 999999999999999999999999999999999999999
    invitable_user_roles = V3::UserRoles::InvitableUserRoles::Index.new(token, user_email, base_url, non_existing_user_role)
    test_rail_result(6, "invitable_user_roles header: #{invitable_user_roles.response.headers}")
    test_rail_result(6, "invitable_user_roles body: #{invitable_user_roles.response.body}")
    expect(invitable_user_roles.response.code).to eq 404
    test_rail_result(6, "invitable_user_roles response code: #{invitable_user_roles.response.code}", "pass")

    #Step7 Using <UserGuest>   (Negative) Verify an authentication fail from Get /v3/user_roles/
    test_rail_expected_result(7, "403 status response with 'Authentication Failed' type error message")
    env_user = DataHandler.get_env_user(env_info, :unauthorized_user)
    user_email = env_user["email"]
    user_password = env_user["password"]
    user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    token = user_session.token
    invitable_user_roles = V3::UserRoles::InvitableUserRoles::Index.new(token, user_email, base_url, 1)
    test_rail_result(7, "invitable_user_roles header: #{invitable_user_roles.response.headers}")
    test_rail_result(7, "invitable_user_roles body: #{invitable_user_roles.response.body}")
    expect(invitable_user_roles.response.code).to eq 403
    test_rail_result(7, "invitable_user_roles response code: #{invitable_user_roles.response.code}", "pass")
  end

end

