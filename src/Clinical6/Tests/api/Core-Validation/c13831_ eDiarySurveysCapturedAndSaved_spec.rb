require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
  let(:env_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { env_user["email"] }
  let(:mobile_user_password) { env_user["password"] }
  let(:device_id) { env_user["device_id"] }


  it 'C13831 Allows user to have their eDiary surveys captured and saved', test_id: 'C13831' do
    test_rail_expected_steps(2)

    #Step1 Make a Post request on {{protocol}}{{url}} /v3/ediary/entries
    test_rail_expected_result(1, "eDiary entry ID is created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(1, "mobile_user_session header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "mobile_user_session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #Post on {{protocol}}{{url}} /v3/ediary/entries
    ediary_entries = V3::Ediary::Entries::Create.new(super_user_session.token, user_email, base_url, mobile_user_id)
    entry_id = ediary_entries.id
    resp_code = ediary_entries.response.code
    test_rail_result(1, "ediary_entries header: #{ediary_entries.response.headers}")
    test_rail_result(1, "ediary_entries body: #{ediary_entries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "creating ediary entries response code: #{resp_code}", "pass")

    #Step2 Make a Get request on {{protocol}}{{url}}/v3/mobile_users/:id/ediary/entries
    test_rail_expected_result(2, "The user receives a 200 OK response with the captured and saved ediary entry")
    #Get request on /v3/mobile_users/:id/ediary/entries
    mobileuser_ediary_entries = V3::MobileUser::Ediary::Entries::Show.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_ediary_entries.response.code
    resp_json = JSON.parse(mobileuser_ediary_entries.response.body)
    test_rail_result(2, "mobileuser_ediary_entries header: #{mobileuser_ediary_entries.response.headers}")
    test_rail_result(2, "mobileuser_ediary_entries body: #{mobileuser_ediary_entries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "getting ediary entry groups of mobile user response code: #{resp_code}", "pass")
    match = resp_json['data'].any? { |data| data.dig('id') == "#{entry_id}"}
    expect(match).to be true
    test_rail_result(2, "new ediary entry in response: #{match} and its id is: #{entry_id}", "pass")
  end

end

