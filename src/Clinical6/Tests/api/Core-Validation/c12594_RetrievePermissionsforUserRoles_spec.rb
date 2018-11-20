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
#Requests


  it 'C12594 - The system should retrieve the permissions for a user role', test_id: 'C12594' do
    test_rail_expected_steps(2)

    #Step1 Make a Get request on /v3/user_roles/{{user_role_id}}/permissions with valid user role id
    test_rail_expected_result(1, "User can get 200 response with all permissions listed for this user role")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    user_role = V3::UserRoles::Index.new(super_user_session.token, user_email, base_url)
    user_role_id = user_role.user_role_id
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

    #Step2 Make a Get request on /v3/user_roles/{{user_role_id}}/permissions with invalid user role id
    test_rail_expected_result(2, "User can get 404 Record Not Found")
    non_existing_user_role = 'nonexisting'
    permission = V3::UserRoles::Permissions::Index.new(super_user_session.token, user_email, base_url, non_existing_user_role)
    test_rail_result(2, "permission body header: #{permission.response.headers}")
    test_rail_result(2, "permission session body: #{permission.response.body}")
    expect(permission.response.code).to eq 404
    test_rail_result(2, "permissions with invalid user role id user role response code: #{permission.response.code}", "pass")
  end
end



