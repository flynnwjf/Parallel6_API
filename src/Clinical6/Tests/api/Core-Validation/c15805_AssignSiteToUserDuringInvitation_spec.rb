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
  let(:testname) { "users_invitation_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:invite_email) { test_data["email"] + DateTime.now.strftime('+%Q').to_s + "@mailinator.com"}
  let(:user_role_id) { test_data["user_role_id"] }
  let(:site_id) { test_data["site_id"] }


  it 'C15805 As a API Client, I want to to be able to assign a Trials::Site to a User during the invitation process', test_id: 'C15805' do
    test_rail_expected_steps(3)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/users/invitation
    test_rail_expected_result(1, "User can get 200 response")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/users/invitation
    user_invitation_create = V3::Users::Invitation::Create.new(super_user_session.token, user_email, base_url, type, invite_email, user_role_id, site_id)
    resp_code = user_invitation_create.response.code
    test_rail_result(1, "user_invitation_create header: #{user_invitation_create.response.headers}")
    test_rail_result(1, "user_invitation_create body: #{user_invitation_create.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "creating user invitation response code: #{resp_code}", "pass")
    resp_json = JSON.parse(user_invitation_create.response.body)
    expect(resp_json.dig('data', 'attributes','email')).to eq invite_email
    test_rail_result(1, "new invited email in response: #{invite_email}", "pass")

    #Step2 The user makes a Post request on {{protocol}}{{url}}/v3/users/invitation
    test_rail_expected_result(2, "User can get 422 response with invalid parameter message")
    #Post request on {{protocol}}{{url}}/v3/users/invitation
    invalid_id = test_data["invalid_id"]
    user_invitation_create = V3::Users::Invitation::Create.new(super_user_session.token, user_email, base_url, type, invite_email, user_role_id, invalid_id)
    resp_code = user_invitation_create.response.code
    test_rail_result(2, "user_invitation_create header: #{user_invitation_create.response.headers}")
    test_rail_result(2, "user_invitation_create body: #{user_invitation_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating user invitation response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a Post request on {{protocol}}{{url}}/v3/users/invitation
    test_rail_expected_result(3, "User can get 403 response with Authorization Failure. You do not have permission to access/modify this resource.")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/users/invitation
    user_invitation_create = V3::Users::Invitation::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, type, invite_email, user_role_id, site_id)
    resp_code = user_invitation_create.response.code
    test_rail_result(3, "user_invitation_create header: #{user_invitation_create.response.headers}")
    test_rail_result(3, "user_invitation_create body: #{user_invitation_create.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "creating user invitation response code: #{resp_code}", "pass")
  end

end

