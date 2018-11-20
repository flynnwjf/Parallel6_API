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
  let(:testname) { "filter_groups_destroy" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test" + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:cohort_type){ test_data["cohort_type"] }
  let(:type){ test_data["type"] }
  let(:valid_id){ test_data["id"] }
  let(:invalid_id){ test_data["invalid_id"] }


  it 'C13235 SDK user should be able to delete a filter group', test_id: 'C13235' do
    test_rail_expected_steps(4)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/filter_groups
    test_rail_expected_result(1, "A new filter group should get created with an id on the response and a 201 Created status")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/filter_groups
    cohort_id = V3::Cohort::Create.new(super_user_session.token, user_email, base_url, name, cohort_type).cohort_id
    filter_group = V3::FilterGroups::Create.new(super_user_session.token, user_email, base_url, type, cohort_id)
    resp_code = filter_group.response.code
    resp_json = JSON.parse(filter_group.response.body)
    test_rail_result(1, "filter_group header: #{filter_group.response.headers}")
    test_rail_result(1, "filter_group body: #{filter_group.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating filter group response code: #{resp_code}", "pass")
    filter_group_id = resp_json.dig('data', 'id')
    expect(filter_group_id).not_to eq nil
    test_rail_result(1, "created filter group id in response: #{filter_group_id}", "pass")

    #Step2 The user makes a DELETE request on {{protocol}}{{url}}/v3/filter_groups{id}
    test_rail_expected_result(2, "User should receive a 204 No content and an empty response")
    #DELETE request on {{protocol}}{{url}}/v3/filter_groups{id}
    filter_group = V3::FilterGroups::Destroy.new(super_user_session.token, user_email, base_url, filter_group_id)
    resp_code = filter_group.response.code
    test_rail_result(2, "filter_group header: #{filter_group.response.headers}")
    test_rail_result(2, "filter_group body: #{filter_group.response.body}")
    expect(resp_code).to eq 204
    test_rail_result(2, "deleting filter group response code: #{resp_code}", "pass")

    #Step3 The user makes a DELETE request on {{protocol}}{{url}}/v3/filter_groups{id} with non existing filter group
    test_rail_expected_result(3, "User should receive 404 Not Found since the filter group was already deleted")
    #DELETE request on {{protocol}}{{url}}/v3/filter_groups{id}
    filter_group = V3::FilterGroups::Destroy.new(super_user_session.token, user_email, base_url, invalid_id)
    resp_code = filter_group.response.code
    test_rail_result(3, "filter_group header: #{filter_group.response.headers}")
    test_rail_result(3, "filter_group body: #{filter_group.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(3, "deleting filter group with non existing filter group response code: #{resp_code}", "pass")

    #Step4 The unauthorized user makes a post request on {{protocol}}{{url}}/v3/filter_groups{id}
    test_rail_expected_result(4, "User should receive a 403 status (Forbidden)")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #DELETE request on {{protocol}}{{url}}/v3/filter_groups{id}
    filter_group = V3::FilterGroups::Destroy.new(unauthorized_user_session.token, unauthorized_user_email, base_url, valid_id)
    resp_code = filter_group.response.code
    test_rail_result(4, "filter_group header: #{filter_group.response.headers}")
    test_rail_result(4, "filter_group body: #{filter_group.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(4, "deleting filter group response code: #{resp_code}", "pass")
  end

end

