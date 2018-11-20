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
#Test Info
  let(:testname) { "mobileuser_invitations_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:email) { "TestEmail" + DateTime.now.strftime('_%Q').to_s + "@parallel6.mailinator.com" }
  let(:member_type) { test_data["member_type"] }
  let(:first_name) { "FirstName" + Time.new.strftime("%Y%m%d") }
  let(:last_name) { "LastName" + Time.new.strftime("%Y%m%d") }
  let(:user_role_id) { test_data["user_role_id"] }
  let(:site_id) { test_data["site_id"] }

  it 'C14710 System should have an ability to generate an email invite to the new users upon their registration in the System', test_id: 'C14710' do
    test_rail_expected_steps(2)

    #Step1 The user makes a POST request on Mobileuser/invitations (with a valid email ID, a selected user_role and optional
    # information on the profile attributes eg: Firstname, Last name etc )
    test_rail_expected_result(1, "200 response code and invitation sent out to user email")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "User session body: #{super_user_session.response.body}")

    invitations_create = V3::MobileUser::Invitations::Create.new(super_user_session.token, user_email, base_url, email, member_type, first_name, last_name, user_role_id, site_id)
    test_rail_result(1, "invitations_create header: #{invitations_create.response.headers}")
    test_rail_result(1, "invitations_create body: #{invitations_create.response.body}")

    expect(invitations_create.response.code).to eq 200
    expect(JSON.parse(invitations_create.response).dig('data', 'attributes', "email").downcase).to eq email.downcase
    test_rail_result(1, "invitations_create response code: #{invitations_create.response.code}")
    test_rail_result(1, "invitations_create email: #{email}", "pass")

    #Step2 The user observes the email inbox of the email ID used
    test_rail_expected_result(2, "The user receives an Invitation email in the Inbox of the user")
    get_inbox = MAILINATOR::GetInbox.new(email)
    test_rail_result(2, "get_inbox header: #{get_inbox.response.headers}")
    test_rail_result(2, "get_inbox body: #{get_inbox.response.body}")
    expect(JSON.parse(get_inbox.response.body).dig('messages', 0 , "subject").downcase).to eq "invitation instructions"
    expect(JSON.parse(get_inbox.response.body).dig('messages', 0 , "from")).to eq "Parallel6"
    expect(get_inbox.response.code).to eq 200
    test_rail_result(2, "get_inbox response code: #{get_inbox.response.code}", "pass")

    #puts get_inbox.response.body
    #puts get_inbox.response.headers
    #puts "first_email_id: #{get_inbox.first_email_id}"

    # get_email = MAILINATOR::GetEmail.new(get_inbox.first_email_id)
    # puts get_email.subject #Invitation Instructions
    # puts get_email.from_field #Parallel6
    # puts "body: #{get_email.email_body}"

  end


end



