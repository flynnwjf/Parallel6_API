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
  let(:testname) { "allowed_actions_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C12829 Admin User able to remove an allowed action that is associated with a permission', test_id: 'C12829' do
    test_rail_expected_steps(4)

    #Step1 With authorization to delete a permission, run a request to delete an allowed action from permission with valid id
    test_rail_expected_result(1, "The response returns No content with 204 status.")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    allowed_action_create = V3::AllowedAction::Create.new(super_user_session.token, user_email, base_url, name)
    allowed_action_id = allowed_action_create.id
    test_rail_result(1, "allowed_action header: #{allowed_action_create.response.headers}")
    test_rail_result(1, "allowed_action body: #{allowed_action_create.response.body}")
    test_rail_result(1, "allowed_action id: #{allowed_action_id}")
    allowed_action_delete = V3::AllowedAction::Delete.new(super_user_session.token, user_email, base_url, allowed_action_id)
    test_rail_result(1, "allowed_action_delete header: #{allowed_action_delete.response.headers}")
    test_rail_result(1, "allowed_action_delete body: #{allowed_action_delete.response.body}")
    expect(allowed_action_delete.response.code).to eq 204
    test_rail_result(1, "allowed_action_delete response code: #{allowed_action_delete.response.code}", "pass")

    #Step2 With authorization to delete a permission, run a request to delete an allowed action from permission with non-existing id
    test_rail_expected_result(2, "The response returns 404 Record Not Found")
    non_existing_allowed_action = 'bad_id'
    allowed_action_delete = V3::AllowedAction::Delete.new(super_user_session.token, user_email, base_url, non_existing_allowed_action)
    test_rail_result(2, "allowed_action_delete header: #{allowed_action_delete.response.headers}")
    test_rail_result(2, "allowed_action_delete body: #{allowed_action_delete.response.body}")
    expect(allowed_action_delete.response.code).to eq 404
    test_rail_result(2, "allowed_action_delete response code: #{allowed_action_delete.response.code}", "pass")

    #Step3 With authorization to delete a permission, run a request to delete an allowed action from permission with non-existing id
    test_rail_expected_result(3, "The response returns 404 Record Not Found")
    non_existing_allowed_action = 99999999999999999999999999999999999999999999999999
    allowed_action_delete = V3::AllowedAction::Delete.new(super_user_session.token, user_email, base_url, non_existing_allowed_action)
    test_rail_result(3, "allowed_action_delete header: #{allowed_action_delete.response.headers}")
    test_rail_result(3, "allowed_action_delete body: #{allowed_action_delete.response.body}")
    expect(allowed_action_delete.response.code).to eq 404
    test_rail_result(3, "allowed_action_delete response code: #{allowed_action_delete.response.code}", "pass")

    #Step4 Without authorization to delete a permission, run a request to delete a permission from a content type.
    test_rail_expected_result(4, "The response returns a 403 status.")
    env_user = DataHandler.get_env_user(env_info, :unauthorized_user)
    user_email = env_user["email"]
    user_password = env_user["password"]
    unauthorized_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(4, "unauthorized_user_session header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "unauthorized_user_session body: #{unauthorized_user_session.response.body}")
    allowed_action_delete = V3::AllowedAction::Delete.new(unauthorized_user_session.token, user_email, base_url, 2)
    test_rail_result(4, "allowed_action_delete header: #{allowed_action_delete.response.headers}")
    test_rail_result(4, "allowed_action_delete body: #{allowed_action_delete.response.body}")
    expect(allowed_action_delete.response.code).to eq 403
    test_rail_result(4, "allowed_action_delete response code: #{allowed_action_delete.response.code}", "pass")

  end

end



