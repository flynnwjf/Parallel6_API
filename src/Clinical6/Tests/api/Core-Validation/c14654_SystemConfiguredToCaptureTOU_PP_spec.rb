require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:mobile_env_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { mobile_env_user["email"] }
  let(:mobile_user_password) { mobile_env_user["password"] }
  let(:device_id) { mobile_env_user["device_id"] }

  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:super_user_email) { env_user["email"] }
  let(:super_user_password) { env_user["password"] }

#Test Info
  let(:testname) { "mobileuser_profile_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:first_name) { "FirstName " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:last_name) { "LastName " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Requests


  it 'C14654 The System should be configurable to capture the date and timestamp of when the user accepts TOU, PP anti-spam policy', test_id: 'C14654' do
    test_rail_expected_steps(5)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users
    test_rail_expected_result(1, "The user should be able to see the response with the privacy_policy_accepted_at  and terms_of_use_accepted_at and see the time that was recorded ")
    mobile_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    mobile_user_id = mobile_session.mobile_user_id
    test_rail_result(1, "mobileuser_create header: #{mobile_session.response.headers}")
    test_rail_result(1, "mobileuser_create body: #{mobile_session.response.body}")
    super_user_token = V3::Users::Session::Create.new(super_user_email, super_user_password, base_url).token
    privacy_policy_date = Date.today
    terms_of_use_date = Date.today
    mobileuser_profile_update = V3::MobileUser::Profile::Update.new(mobile_user_id, super_user_token, super_user_email, base_url, first_name, last_name, 'America/Tijuana', privacy_policy_date , terms_of_use_date)
    test_rail_result(1, "mobileuser_profile_update header: #{mobileuser_profile_update.response.headers}")
    test_rail_result(1, "mobileuser_profile_update body: #{mobileuser_profile_update.response.body}")
    expect(mobileuser_profile_update.response.code).to eq 200
    terms_of_use_accepted_at =  Date.parse(JSON.parse(mobileuser_profile_update.response).dig('data', 'attributes', 'terms_of_use_accepted_at'), "%m/%d/%Y")
    privacy_policy_accepted_at =  Date.parse(JSON.parse(mobileuser_profile_update.response).dig('data', 'attributes', 'privacy_policy_accepted_at'), "%m/%d/%Y")
    expect(terms_of_use_accepted_at).to eq terms_of_use_date
    expect(privacy_policy_accepted_at).to eq privacy_policy_date
    test_rail_result(1, "privacy_policy_date: #{privacy_policy_accepted_at}")
    test_rail_result(1, "terms_of_use_date: #{terms_of_use_date}", "pass")

    #Step2 The user makes a GET request to {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/profile
    test_rail_expected_result(2, " The user should see that the response have the captured date and time of privacy_policy_accepted_at and terms_of_use_accepted_at ")
    mobileuser_profile_get = V3::MobileUser::Profile::Show.new(mobile_user_id, super_user_token, super_user_email, base_url)
    test_rail_result(2, "mobileuser_profile_get header: #{mobileuser_profile_get.response.headers}")
    test_rail_result(2, "mobileuser_profile_get body: #{mobileuser_profile_get.response.body}")
    terms_of_use_accepted_at =  Date.parse(JSON.parse(mobileuser_profile_get.response).dig('data', 'attributes', 'terms_of_use_accepted_at'), "%m/%d/%Y")
    privacy_policy_accepted_at =  Date.parse(JSON.parse(mobileuser_profile_get.response).dig('data', 'attributes', 'privacy_policy_accepted_at'), "%m/%d/%Y")
    expect(terms_of_use_accepted_at).to eq terms_of_use_date
    expect(privacy_policy_accepted_at).to eq privacy_policy_date
    test_rail_result(2, "privacy_policy_date: #{privacy_policy_accepted_at}")
    test_rail_result(2, "terms_of_use_date: #{terms_of_use_date}", "pass")

    #Step3 The user makes a PATCH request to {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/profile  with a non existent mobile_user_id
    test_rail_expected_result(3, " The user receives a 404 not found status as a response ")
    mobileuser_profile_get = V3::MobileUser::Profile::Show.new("11111111", super_user_token, super_user_email, base_url)
    test_rail_result(3, "mobileuser_profile_get header: #{mobileuser_profile_get.response.headers}")
    test_rail_result(3, "mobileuser_profile_get body: #{mobileuser_profile_get.response.body}")
    expect(mobileuser_profile_get.response.code).to eq 404
    test_rail_result(3, "mobileuser_profile_get response code: #{mobileuser_profile_get.response.code}", "pass")

    #Step4 The user makes a Delete request to {{protocol}}{{url}} /v3/users/sessions
    test_rail_expected_result(4, " The user receives 204 status and the session is expired ")
    session_cleanup =V3::Users::Session::Delete.new(super_user_token, super_user_email, base_url)
    test_rail_result(4, "session_cleanup header: #{session_cleanup.response.headers}")
    test_rail_result(4, "session_cleanup body: #{session_cleanup.response.body}")
    expect(session_cleanup.response.code).to eq 204
    test_rail_result(4, "session_cleanup response code: #{session_cleanup.response.code}", "pass")

    #Step5 The user makes a PATCH request to {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/profile
    test_rail_expected_result(5, " The user receives 401 unauthorized  as the user session is expired")
    mobileuser_profile_update = V3::MobileUser::Profile::Update.new(mobile_user_id, super_user_token, super_user_email, base_url, first_name, last_name, 'America/Tijuana', privacy_policy_date , terms_of_use_date)
    test_rail_result(5, "mobileuser_profile_update header: #{mobileuser_profile_update.response.headers}")
    test_rail_result(5, "mobileuser_profile_update body: #{mobileuser_profile_update.response.body}")
    expect(mobileuser_profile_update.response.code).to eq 401
    test_rail_result(5, "mobileuser_profile_update response code: #{mobileuser_profile_update.response.code}", "pass")


  end

end

