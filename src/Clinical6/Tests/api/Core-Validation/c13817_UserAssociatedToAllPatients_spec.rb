require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
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


  it 'C13817 User should be automatically associated to all patients', test_id: 'C13817' do
      test_rail_expected_steps(2)

      #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/mobile_users/invitation
      test_rail_expected_result(1, "User should receive 200 status and get the created mobile_user_id")
      #Super User Session
      super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
      test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
      test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
      #POST request on {{protocol}}{{url}}/v3/mobile_users/invitations
      invitation_mobile_user = V3::MobileUser::Invitations::Create.new(super_user_session.token, user_email, base_url, email, member_type, first_name, last_name, user_role_id, site_id)
      resp_code = invitation_mobile_user.response.code
      test_rail_result(1, "invitation_mobile_user header: #{invitation_mobile_user.response.headers}")
      test_rail_result(1, "invitation_mobile_user body: #{invitation_mobile_user.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(1, "mobile user invitation response code: #{resp_code}", "pass")
      mobile_user_id = invitation_mobile_user.id

      #Step2 The user makes a GET request on {{protocol}{{url}}/v3/mobile_users/{{mobile_user_id1}}/related_users
      test_rail_expected_result(2, "User should be able to see that new users that were created and the rest of the users that are associated with that main user")
      #GET request on {{protocol}{{url}}/v3/mobile_users/{{mobile_user_id1}}/related_users
      mobileuser_relatedusers = V3::MobileUser::RelatedUsers::Show.new(super_user_session.token, user_email, base_url, mobile_user_id)
      resp_code = mobileuser_relatedusers.response.code
      resp_json = JSON.parse(mobileuser_relatedusers.response.body)
      test_rail_result(2, "mobileuser_relatedusers header: #{mobileuser_relatedusers.response.headers}")
      test_rail_result(2, "mobileuser_relatedusers body: #{mobileuser_relatedusers.response.body}")
      expect(resp_code).to eq 200
      test_rail_result(2, "listing mobile user related user response code: #{resp_code}", "pass")
      related = resp_json['included'].any? { |user| user.dig('relationships', 'patient', 'data', 'id') != nil}
      expect(related).to be true
      test_rail_result(2, "mobile user related user in response: #{related}", "pass")
  end

end

