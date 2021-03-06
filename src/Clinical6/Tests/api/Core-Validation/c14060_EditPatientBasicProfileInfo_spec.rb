require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_email) { mobile_user["email"] }
  let(:mobile_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
#Test Info
  let(:testname) { "mobileuser_profile_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:first_name) { "FirstName" + Time.new.strftime("%Y%m%d") }
  let(:last_name) { "LastName" + Time.new.strftime("%Y%m%d") }


  it 'C14060 User can edit patient\'s basic profile information', test_id: 'C14060' do
    test_rail_expected_steps(3)

    #Step1 The user makes a Get request on /v3/mobile_users/:id/profile
    test_rail_expected_result(1, "The mobile user's profile is displayed.")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    mobile_user_token = mobile_user_session.token
    #Get request on /v3/mobile_users/:id/profile
    user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_session.token, user_email, base_url)
    resp_code = user_profile_show.response.code
    test_rail_result(1, "user_profile_show header: #{user_profile_show.response.headers}")
    test_rail_result(1, "user_profile_show body: #{user_profile_show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "showing user profile response code: #{resp_code}", "pass")

    #Step2 The user makes a Patch request on /v3/mobile_users/:id/profile
    test_rail_expected_result(2, "The mobile user's profile is updated.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(2, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(2, "Super User session body: #{super_user_session.response.body}")
    #Patch request on /v3/mobile_users/:id/profile
    user_profile_update = V3::MobileUser::Profile::Update.new(mobile_user_id, super_user_session.token, user_email, base_url, first_name, last_name)
    resp_code = user_profile_update.response.code
    resp_json = JSON.parse(user_profile_update.response.body)
    test_rail_result(2, "user_profile_update header: #{user_profile_update.response.headers}")
    test_rail_result(2, "user_profile_update body: #{user_profile_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "updating user profile response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'first_name')).to eq first_name
    expect(resp_json.dig('data', 'attributes', 'last_name')).to eq last_name
    test_rail_result(2, "updated FN and LN in response: #{first_name} + #{last_name}", "pass")

    #Step3 The user makes a Get request on /v3/mobile_users/:id/profile
    test_rail_expected_result(3, "The mobile user's profile with the updates are displayed.")
    #Get request on /v3/mobile_users/:id/profile
    user_profile_show = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_session.token, user_email, base_url)
    resp_code = user_profile_show.response.code
    resp_json = JSON.parse(user_profile_show.response.body)
    test_rail_result(3, "user_profile_show header: #{user_profile_update.response.headers}")
    test_rail_result(3, "user_profile_show body: #{user_profile_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "showing user profile response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'first_name')).to eq first_name
    expect(resp_json.dig('data', 'attributes', 'last_name')).to eq last_name
    test_rail_result(3, "showing updated FN and LN in response: #{first_name} + #{last_name}", "pass")
  end

end

