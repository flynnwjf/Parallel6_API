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
  let(:testname) { "mobileuser_invitations_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:email) { "TestEmail" + DateTime.now.strftime('+%Q').to_s + "@mailinator.com"}
  let(:member_type) { test_data["member_type"] }
  let(:first_name) { "FirstName" + Time.new.strftime("%Y%m%d") }
  let(:last_name) { "LastName" + Time.new.strftime("%Y%m%d") }
  let(:user_role_id) { test_data["user_role_id"] }
  let(:site_id) { test_data["site_id"] }


  it 'C13666 User should be able to create a mobile user account name with an empty string', test_id: 'C13666' do
    test_rail_expected_steps(2)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users/invitations with null value on First name and Last name
    test_rail_expected_result(1, "It returns a 200 response and the details of the created user with a null value on First name and Last name.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/mobile_users/invitations with null value on First name and Last name
    invitation = V3::MobileUser::Invitations::Create.new(super_user_session.token, user_email, base_url, email, member_type, "", "", user_role_id, site_id)
    resp_code = invitation.response.code
    resp_json = JSON.parse(invitation.response.body)
    test_rail_result(1, "invitation header: #{invitation.response.headers}")
    test_rail_result(1, "invitation body: #{invitation.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "inviting mobile user response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes',"first_name")).to eq nil
    expect(resp_json.dig('data', 'attributes',"last_name")).to eq nil
    test_rail_result(1, "null FN and LN in response", "pass")

    #Step2 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users/invitations with null value on Email
    test_rail_expected_result(2, "It returns 422 response")
    #Post request on {{protocol}}{{url}}/v3/mobile_users/invitations with null value on Email
    invitation = V3::MobileUser::Invitations::Create.new(super_user_session.token, user_email, base_url, "", member_type, first_name, last_name, user_role_id, site_id)
    resp_code = invitation.response.code
    test_rail_result(2, "invitation header: #{invitation.response.headers}")
    test_rail_result(2, "invitation body: #{invitation.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "inviting mobile user response code: #{resp_code}", "pass")
  end

end

