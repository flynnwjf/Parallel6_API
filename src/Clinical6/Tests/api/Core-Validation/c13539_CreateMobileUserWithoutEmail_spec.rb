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
  let(:testname) { "mobile_user_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:mobile_user_email) { "" }
  let(:invalid_id) { test_data["invalid_id"] }
  let(:user_role_id) { test_data["user_role_id"] }


  it 'C13539 Allows user to create a patient without specifying an email address', test_id: 'C13539' do
    test_rail_expected_steps(2)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users
    test_rail_expected_result(1, "REST Tool returns an error, and the user is not created.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/mobile_users
    mobileuser_create = V3::MobileUser::Create.new(super_user_session.token, user_email, base_url, type, mobile_user_email, invalid_id)
    resp_code = mobileuser_create.response.code
    test_rail_result(1, "mobileuser_create header: #{mobileuser_create.response.headers}")
    test_rail_result(1, "mobileuser_create body: #{mobileuser_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(1, "creating mobile user response code: #{resp_code}", "pass")

    #Step2 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users
    test_rail_expected_result(2, "REST Tool returns a 201 response and returns the user profile.")
    #Post request on {{protocol}}{{url}}/v3/mobile_users
    mobileuser_create = V3::MobileUser::Create.new(super_user_session.token, user_email, base_url, type, mobile_user_email, user_role_id)
    resp_code = mobileuser_create.response.code
    resp_json = JSON.parse(mobileuser_create.response.body)
    test_rail_result(2, "mobileuser_create header: #{mobileuser_create.response.headers}")
    test_rail_result(2, "mobileuser_create body: #{mobileuser_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(2, "creating mobile user response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'invitation_sent_at')).to eq nil
    expect(resp_json.dig('data', 'attributes', 'invitation_accepted_at')).to eq nil
    test_rail_result(2, "invitation_sent_at and invitation_accepted_at in response", "pass")
  end

end

