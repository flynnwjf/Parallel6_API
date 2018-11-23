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


  it 'C12559 The application should expire a user\'s session after a certain period of inactivity', test_id: 'C12559' do
    test_rail_expected_steps(8)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/users/sessions
    test_rail_expected_result(1, "Session is created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    #POST request on {{protocol}}{{url}}/v3/users/sessions
    resp_code = super_user_session.response.code
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating super_user_session response code: #{resp_code}", "pass")
    user_id = super_user_session.user_id
    user_token = super_user_session.token

    #Step2 The user makes a Get request on /v3/users/:id/profile
    test_rail_expected_result(2, "The user's profile is retrieved in the response")
    #Get request on /v3/users/:id/profile
    user_profile_show = V3::Users::Profile::Show.new(user_id, user_token, user_email, base_url)
    resp_code = user_profile_show.response.code
    test_rail_result(2, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(2, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "showing user profile response code: #{resp_code}", "pass")

    #Step3 The user makes a Get request on /v3/users/:id/profile after 10 mins
    test_rail_expected_result(3, "The session gets extended for another 15 minutes")
    sleep(10*60)
    #Get request on /v3/users/:id/profile
    user_profile_show = V3::Users::Profile::Show.new(user_id, user_token, user_email, base_url)
    resp_code = user_profile_show.response.code
    test_rail_result(3, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(3, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "showing user profile response code: #{resp_code}", "pass")

    #Step4 The user makes a Get request on /v3/users/:id/profile after 15 mins
    test_rail_expected_result(4, "Error message is displayed 401 unauthorized")
    sleep(16*60)
    #Get request on /v3/users/:id/profile
    user_profile_show = V3::Users::Profile::Show.new(user_id, user_token, user_email, base_url)
    resp_code = user_profile_show.response.code
    test_rail_result(4, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(4, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 401
    test_rail_result(4, "showing user profile response code: #{resp_code}", "pass")

    #Step5 The user makes a POST request on {{protocol}}{{url}}/v3/users/sessions
    test_rail_expected_result(5, "Session is created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    #POST request on {{protocol}}{{url}}/v3/users/sessions
    resp_code = super_user_session.response.code
    test_rail_result(5, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(5, "super_user_session body: #{super_user_session.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(5, "creating super_user_session response code: #{resp_code}", "pass")
    user_id = super_user_session.user_id
    user_token = super_user_session.token

    #Step6 The user makes a Get request on /v3/users/:id/profile
    test_rail_expected_result(6, "The user's profile is retrieved in the response")
    #Get request on /v3/users/:id/profile
    user_profile_show = V3::Users::Profile::Show.new(user_id, user_token, user_email, base_url)
    resp_code = user_profile_show.response.code
    test_rail_result(6, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(6, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(6, "showing user profile response code: #{resp_code}", "pass")

    #Step7 The user makes a Get request on /v3/users/:id/profile
    test_rail_expected_result(7, "The response should be successful 200")
    #Get request on /v3/users/:id/profile
    time = 6*60*60
    count = 0
    cal = 10*60
    while count<time
      user_profile_show = V3::Users::Profile::Show.new(user_id, user_token, user_email, base_url)
      resp_code = user_profile_show.response.code
      expect(resp_code).to eq 200
      count = count + cal
      sleep(cal)
    end
    test_rail_result(7, "showing user profile response code: #{resp_code}", "pass")

    #Step8 The user makes a Get request on /v3/users/:id/profile
    test_rail_expected_result(8, "Error message is displayed 401 unauthorized")
    sleep(10*60)
    #Get request on /v3/users/:id/profile
    user_profile_show = V3::Users::Profile::Show.new(user_id, user_token, user_email, base_url)
    resp_code = user_profile_show.response.code
    test_rail_result(8, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(8, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 401
    test_rail_result(8, "showing user profile response code: #{resp_code}", "pass")
  end

end

