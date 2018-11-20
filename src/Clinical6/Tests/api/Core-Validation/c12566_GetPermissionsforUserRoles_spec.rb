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
  let(:testname) { "userroles_permissions_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C12566 App developer should be able to get a list of permissions based on user role id', test_id: 'C12566' do
    test_rail_expected_steps(4)

    #Step1 Make a Get request on /v3/user_roles/{{user_role_id}}/permissions with valid user role id
    test_rail_expected_result(1, "User can get 200 response with all permissions listed for this user role")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    user_role = V3::UserRoles::Index.new(super_user_session.token, user_email, base_url)
    user_role_id = user_role.user_role_id
    test_rail_result(1, "user_role_id body header: #{user_role.response.headers}")
    test_rail_result(1, "user_role_id session body: #{user_role.response.body}")
    test_rail_result(1, "user_role_id: #{user_role_id}")
    permission = V3::UserRoles::Permissions::Index.new(super_user_session.token, user_email, base_url, user_role_id)
    test_rail_result(1, "permission body header: #{permission.response.headers}")
    test_rail_result(1, "permission session body: #{permission.response.body}")
    expect(permission.response.code).to eq 200
    test_rail_result(1, "user_roles status response code: #{permission.response.code}")
    resp_json = JSON.parse(permission.response.body)
    id = resp_json['data'].all? { |permission| permission.dig('id') != nil }
    type = resp_json['data'].all? { |permission| permission.dig('type') == 'permissions' }
    expect(id).to be true
    expect(type).to be true
    test_rail_result(1, "id(s) contained in response: #{id}")
    test_rail_result(1, "type(s) contained in response: #{type}", "pass")
    #resp_json['data'].each { |permission| puts permission.dig('id') }

    #Step2 Make a Get request on /v3/user_roles/{{user_role_id}}/permissions with non-existing user role id
    test_rail_expected_result(2, "User can get 404 Record Not Found")
    non_existing_user_role = 'bad_id'
    permission = V3::UserRoles::Permissions::Index.new(super_user_session.token, user_email, base_url, non_existing_user_role)
    test_rail_result(2, "permission body header: #{permission.response.headers}")
    test_rail_result(2, "permission session body: #{permission.response.body}")
    expect(permission.response.code).to eq 404
    test_rail_result(2, "permissions of non-existing user role response code: #{permission.response.code}", "pass")

    #Step3 Make a Get request on /v3/user_roles/{{user_role_id}}/permissions with zero user role id
    test_rail_expected_result(3, "User can get 404 Record Not Found")
    non_existing_user_role = 0
    permission = V3::UserRoles::Permissions::Index.new(super_user_session.token, user_email, base_url, non_existing_user_role)
    test_rail_result(3, "permission body header: #{permission.response.headers}")
    test_rail_result(3, "permission session body: #{permission.response.body}")
    expect(permission.response.code).to eq 404
    test_rail_result(3, "permissions of zero user role response code: #{permission.response.code}", "pass")

    #Step4 Make a Get request on /v3/user_roles/{{user_role_id}}/permissions with large number of user role id
    test_rail_expected_result(4, "User can get 404 Record Not Found")
    non_existing_user_role = 99999999999999999999999999999999999999999999999999
    permission = V3::UserRoles::Permissions::Index.new(super_user_session.token, user_email, base_url, non_existing_user_role)
    test_rail_result(4, "permission body header: #{permission.response.headers}")
    test_rail_result(4, "permission session body: #{permission.response.body}")
    expect(permission.response.code).to eq 404
    test_rail_result(4, "permissions of large number user role response code: #{permission.response.code}", "pass")
  end

end


