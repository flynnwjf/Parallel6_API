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
#Test Info
  let(:testname) { "ediary_entrygroups_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C14300 Users should be able to view the eDiary surveys in organized groups', test_id: 'C14300' do
    test_rail_expected_steps(3)

    #Step1 Make a Post request on /v3/mobile_users/sessions
    test_rail_expected_result(1, "User can get mobile user's id")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    #POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
    resp_code = mobile_user_session.response.code
    test_rail_result(1, "mobile_user_session header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "mobile_user_session body: #{mobile_user_session.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "creating mobile_user_session response code: #{resp_code}", "pass")
    mobile_user_id = mobile_user_session.mobile_user_id

    #Step2 Make a Get request on /v3/ediary/entry_groups
    test_rail_expected_result(2, "User can get entry group id")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(2, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(2, "super_user_session body: #{super_user_session.response.body}")
    #Get request on /v3/ediary/entry_groups
    ediary_entrygroups_index = V3::Ediary::EntryGroups::Index.new(super_user_session.token, user_email, base_url)
    resp_code = ediary_entrygroups_index.response.code
    test_rail_result(2, "ediary_entrygroups_index header: #{ediary_entrygroups_index.response.headers}")
    test_rail_result(2, "ediary_entrygroups_index body: #{ediary_entrygroups_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "getting ediary entry groups response code: #{resp_code}", "pass")

    #Step3 Make a Get request on /v3/mobile_users/:id/ediary/entries
    test_rail_expected_result(3, "User can get entry group id")
    #Get request on /v3/mobile_users/:id/ediary/entries
    mobileuser_ediary_entries = V3::MobileUser::Ediary::Entries::Show.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_ediary_entries.response.code
    test_rail_result(3, "mobileuser_ediary_entries header: #{mobileuser_ediary_entries.response.headers}")
    test_rail_result(3, "mobileuser_ediary_entries body: #{mobileuser_ediary_entries.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting ediary entry groups of mobile user response code: #{resp_code}", "pass")
  end

end

