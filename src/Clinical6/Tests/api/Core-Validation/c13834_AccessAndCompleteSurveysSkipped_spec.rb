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
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:date) { Time.new.strftime("%Y-%m-%d") }


  it 'C13834 Allows user to access and complete previous eDiary surveys that may have skipped', test_id: 'C13834' do
    test_rail_expected_steps(4)

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
    test_rail_result(2, "new ediary entry in response: #{match}", "pass")

    #Step3 Make a Patch request on {{protocol}}{{url}} /v3/ediary/entries/:id
    test_rail_expected_result(3, "The created entry from the previous response is updated and completed")
    #Patch on {{protocol}}{{url}} /v3/ediary/entries/:id
    ediary_entries_update = V3::Ediary::Entries::Update.new(super_user_session.token, user_email, base_url, entry_id, mobile_user_id, date)
    resp_code = ediary_entries_update.response.code
    resp_json = JSON.parse(ediary_entries_update.response.body)
    test_rail_result(3, "ediary_entries_update header: #{ediary_entries_update.response.headers}")
    test_rail_result(3, "ediary_entries_update body: #{ediary_entries_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "updating ediary entries response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'date')).to eq date
    test_rail_result(3, "updated value of ediary entry in response", "pass")

    #Step4 Make a Post request on {{protocol}}{{url}} /v3/ediary/entries
    test_rail_expected_result(4, "User should not be able to create an ediary entry ID and should observe a 403 Unauthorized status")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Post on {{protocol}}{{url}} /v3/ediary/entries
    ediary_entries = V3::Ediary::Entries::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, mobile_user_id)
    resp_code = ediary_entries.response.code
    test_rail_result(4, "ediary_entries header: #{ediary_entries.response.headers}")
    test_rail_result(4, "ediary_entries body: #{ediary_entries.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(4, "creating ediary entries response code: #{resp_code}", "pass")
  end

end

