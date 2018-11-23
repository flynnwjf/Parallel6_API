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


  it 'C13763 The system shall allow alerts to be associated to a specific patient', test_id: 'C13763' do
    test_rail_expected_steps(4)

    #Step1 The user makes a GET request on /v3/:resource/:resource_id/notifications/deliveries
    test_rail_expected_result(1, "Count the number of returned responses")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #GET request on /v3/:resource/:resource_id/notifications/deliveries
    mobileuser_notifications_deliveries = V3::MobileUser::Notifications::Deliveries::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_notifications_deliveries.response.code
    test_rail_result(1, "mobileuser_notifications_deliveries header: #{mobileuser_notifications_deliveries.response.headers}")
    test_rail_result(1, "mobileuser_notifications_deliveries body: #{mobileuser_notifications_deliveries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "showing mobile user notifications deliveries response code: #{resp_code}", "pass")
    count_original = mobileuser_notifications_deliveries.count

    #Step2 The user makes a Patch request on /v3/mobile_users/:id/profile
    test_rail_expected_result(2, "The mobile user's profile is updated.")
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
    sleep(60)

    #Step3 The user makes a GET request on /v3/:resource/:resource_id/notifications/deliveries
    test_rail_expected_result(3, "There should be one more response than the number of responses in step 1")
    #GET request on /v3/:resource/:resource_id/notifications/deliveries
    mobileuser_notifications_deliveries = V3::MobileUser::Notifications::Deliveries::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_notifications_deliveries.response.code
    test_rail_result(3, "mobileuser_notifications_deliveries header: #{mobileuser_notifications_deliveries.response.headers}")
    test_rail_result(3, "mobileuser_notifications_deliveries body: #{mobileuser_notifications_deliveries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "showing mobile user notifications deliveries response code: #{resp_code}", "pass")
    count_after_patch = mobileuser_notifications_deliveries.count
    expect(count_original < count_after_patch).to be true
    test_rail_result(3, "count of mobile user notifications deliveries is larger that step 1", "pass")

    #Step4 Check user email
    test_rail_expected_result(4, "There is an email notifying that mobile_user updated their profile")
    get_inbox = MAILINATOR::GetInbox.new(user_email)
    test_rail_result(4, "get_inbox header: #{get_inbox.response.headers}")
    test_rail_result(4, "get_inbox body: #{get_inbox.response.body}")
    expect(JSON.parse(get_inbox.response.body).dig('messages', 0 , "subject").downcase).to eq "patient profile is updated"
    expect(JSON.parse(get_inbox.response.body).dig('messages', 0 , "from")).to eq "Parallel6"
    expect(get_inbox.response.code).to eq 200
    test_rail_result(4, "get_inbox response code: #{get_inbox.response.code}", "pass")
  end

end

