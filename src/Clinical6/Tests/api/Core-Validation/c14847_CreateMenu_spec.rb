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
  let(:testname) { "menus_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:invalid_title) { test_data["invalid_title"] }


  it 'C14847 As a SDK User, I want to be able to create a Menu that is associated with another menu', test_id: 'C14847'  do
    test_rail_expected_steps(3)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/menus
    test_rail_expected_result(1, "User should get a 201 create response and see id, type, attributes and relationships in response")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/menus
    menu_create = V3::Menus::Create.new(super_user_session.token, user_email, base_url, type, title)
    menu_id = menu_create.id
    resp_code = menu_create.response.code
    resp_json = JSON.parse(menu_create.response.body)
    test_rail_result(1, "menu_create header: #{menu_create.response.headers}")
    test_rail_result(1, "menu_create body: #{menu_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating menu response code: #{resp_code}", "pass")
    expect(menu_id).not_to eq nil
    expect(resp_json.dig('data', 'type')).to eq type
    test_rail_result(1, "created menu id in response: #{menu_id}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/menus with invalid parameter
    test_rail_expected_result(2, "User should get a 422 Unprocessable Entity response")
    #POST request on {{protocol}}{{url}}/v3/menus with invalid parameter
    menu_create = V3::Menus::Create.new(super_user_session.token, user_email, base_url, type, invalid_title)
    resp_code = menu_create.response.code
    test_rail_result(2, "menu_create header: #{menu_create.response.headers}")
    test_rail_result(2, "menu_create body: #{menu_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating menu with invalid parameters response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a POST request on {{protocol}}{{url}}/v3/menus
    test_rail_expected_result(3, "User should get a 403 and authorization is failed")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/cohorts
    menu_create = V3::Menus::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, type, title)
    resp_code = menu_create.response.code
    test_rail_result(3, "menu_create header: #{menu_create.response.headers}")
    test_rail_result(3, "menu_create body: #{menu_create.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "creating menu response code: #{resp_code}", "pass")
  end

end

