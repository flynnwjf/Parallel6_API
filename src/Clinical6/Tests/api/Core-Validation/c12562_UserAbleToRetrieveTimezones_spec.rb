require_relative '../../../../../src/spec_helper'
require 'json'

context 'Core Test', test_rail: true do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { mobile_user["email"] }
  let(:mobile_user_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }

#Test Info
  #let(:testname) { "cTBD" }
  #let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C12562 - The system shall allow  ≥≤≥≥a user to select a preferred timezone from a list of available time zones', test_id: 'C12562' do
    test_rail_expected_steps(2)

    #Step1 Using REST Tool V3 API Collection, go to Timezones > Index (GET)
    test_rail_expected_result(1, "GET method '{{protocol}}{{url}}/v3/timezones?sort=offset' is generated.")

    new_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    new_session_token = new_session.token
    test_rail_result(1, "response header: #{new_session.response.headers}")
    test_rail_result(1, "response body: #{new_session.response.body}")
    expect(new_session.response.code).to eq 201
    test_rail_result(1, "new session response code: #{new_session.response.code}")

    timezones = V3::Timezones::Index.new(base_url)
    test_rail_result(1, "timezones header: #{timezones.response.headers}")
    test_rail_result(1, "timezones body: #{timezones.response.body}")
    expect(timezones.response.code).to eq 200
    resp_json = JSON.parse(timezones.response.body)
    gmt_included = resp_json['data'].all? { |menu| menu.dig('attributes','offset') != nil }
    #expect(JSON.parse(timezones.response.body).dig("data", 0,"gmc")).to contain gmc
    test_rail_result(1, "timezones response code: #{timezones.response.code}")
    test_rail_result(1, "timezones contain GMT offset: #{gmt_included}", "pass")

    #Step2 The user makes a Patch request to Mobile user/profile endpoint (with a valid users profile id and a valid timezone
    # from the list of timezones {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/profile
    test_rail_expected_result(2, "The users timezone is updated in the users profile")
    random_language_number = rand(1...20)
    random_language = resp_json.dig('data', random_language_number, 'attributes', 'name')
    test_rail_result(2, "Timezone being updated to: #{random_language} ")

    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(2, "mobile_user_session header: #{mobile_user_session.response.headers}")
    test_rail_result(2, "mobile_user_session body: #{mobile_user_session.response.body}")

    profile_update = V3::MobileUser::Profile::Update.new(mobile_user_session.id, new_session_token ,user_email, base_url, "John", "Smith", random_language)
    test_rail_result(2, "profile_update header: #{profile_update.response.headers}")
    test_rail_result(2, "profile_update body: #{profile_update.response.body}")
  #  resp_json = JSON.parse(update_language.response)
    expect(profile_update.response.code).to eq 200
    test_rail_result(2, "profile_update response code: #{profile_update.response.code}")
    resp_json = JSON.parse(profile_update.response.body)
    expect(resp_json.dig("data","attributes","timezone")).to eq random_language
    test_rail_result(2, "random language #{random_language} was correct", "pass")
  end
end
