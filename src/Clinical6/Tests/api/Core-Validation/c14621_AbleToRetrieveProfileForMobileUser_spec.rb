require_relative '../../../../../src/spec_helper'
require 'date'
context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_email) { mobile_user["email"] }
  let(:mobile_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
#Test Info
  let(:testname) { "mobileuser_invitations_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:email) { "TestEmail" + DateTime.now.strftime('_%Q').to_s + "@parallel6.mailinator.com" }
  let(:member_type) { test_data["member_type"] }
  let(:first_name) { "FirstName" + Time.new.strftime("%Y%m%d") }
  let(:last_name) { "LastName" + Time.new.strftime("%Y%m%d") }
  let(:user_role_id) { test_data["user_role_id"] }
  let(:site_id) { test_data["site_id"] }


  it 'C14621 The System Administrator should be able to retrieve the profile associated with a mobile user', test_id: 'C14621' do
    test_rail_expected_steps(2)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/invitation
    test_rail_expected_result(1, "The user gets 200 OK response and the created mobile_user_id")
    new_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "new_session header: #{new_session.response.headers}")
    test_rail_result(1, "new_session body: #{new_session.response.body}")
    expect(new_session.response.code).to eq 201
    invitations_create = V3::MobileUser::Invitations::Create.new(new_session.token, user_email, base_url, email, member_type, first_name, last_name, user_role_id, site_id)
    test_rail_result(1, "invitations_create header: #{invitations_create.response.headers}")
    test_rail_result(1, "invitations_create body: #{invitations_create.response.body}")
    expect(invitations_create.response.code).to eq 200
    test_rail_result(1, "invitations_create response code: #{invitations_create.response.code}")
    mobile_user_id = invitations_create.id
    expect(mobile_user_id).not_to eq nil
    test_rail_result(1, "created mobile_user_id: #{mobile_user_id}", "pass")

    #Step2 The user makes a GET request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/profile
    # with valid mobile_user_id which is created in step 1
    test_rail_expected_result(2, "The user gets a 200 response and the users profile is displayed")

    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(2, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(2, "Mobile User session body: #{mobile_user_session.response.body}")


    mobileuser_profile = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_session.token, user_email, base_url)
    test_rail_result(2, "mobileuser_profile header: #{mobileuser_profile.response.headers}")
    test_rail_result(2, "mobileuser_profile body: #{mobileuser_profile.response.body}")
    expect(invitations_create.response.code).to eq 200
    test_rail_result(2, "invitations_create response code: #{mobileuser_profile.response.code}")

    expect(JSON.parse(mobileuser_profile.response.body).dig("included", 0, "id")).to eq mobile_user_id
    test_rail_result(2, "invitations_create contained mobileuser id: #{mobile_user_id} : true", "pass")
  end
end




