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
  let(:testname) { "user_sessions_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C14714 Support for: destruction of User Session upon log-out', test_id: 'C14714' do
    test_rail_expected_steps(4)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/users/sessions
    test_rail_expected_result(1, "record the provided access token")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    #POST request on {{protocol}}{{url}}/v3/users/sessions
    resp_code = super_user_session.response.code
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    expect(resp_code).to eq 201
    expect(super_user_session.token.length).to be 64
    test_rail_result(1, "creating super_user_session response code: #{resp_code}", "pass")
    user_id = super_user_session.user_id
    user_token = super_user_session.token

    #Step2 The user makes a Get request on /v3/users/:id/profile
    test_rail_expected_result(2, "successful (200) response from the platform")
    #Get request on /v3/users/:id/profile
    user_profile_show = V3::Users::Profile::Show.new(user_id, user_token, user_email, base_url)
    resp_code = user_profile_show.response.code
    resp_json = JSON.parse(user_profile_show.response.body)
    test_rail_result(2, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(2, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "showing user profile response code: #{resp_code}", "pass")
    expect(resp_json.dig('included', 0, 'id')).to eq user_id

    #Step3 The user makes a Delete request on v3/users/sessions
    test_rail_expected_result(3, "no content (204) response from the platform")
    #Delete request on v3/users/sessions
    delete_user_session = V3::Users::Session::Delete.new(user_token, user_email,base_url)
    resp_code = delete_user_session.response.code
    test_rail_result(3, "delete_user_session header: #{delete_user_session.response.headers}")
    test_rail_result(3, "delete_user_session body: #{delete_user_session.response.body}")
    expect(resp_code).to eq 204
    test_rail_result(3, "deleting user session response code: #{resp_code}", "pass")

    #Step4 The user makes a Get request on /v3/users/:id/profile
    test_rail_expected_result(4, "unauthorized (401) response from the platform")
    #Get request on /v3/users/:id/profile
    user_profile_show = V3::Users::Profile::Show.new(user_id, user_token, user_email, base_url)
    resp_code = user_profile_show.response.code
    resp_json = JSON.parse(user_profile_show.response.body)
    test_rail_result(4, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(4, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 401
    test_rail_result(4, "showing user profile response code: #{resp_code}", "pass")
  end

end

