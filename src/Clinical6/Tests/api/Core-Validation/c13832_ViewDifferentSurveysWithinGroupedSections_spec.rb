require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "consent_approvers_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C13832 Allows user to view different eDiary surveys within grouped sections', test_id: 'C13832' do
    test_rail_expected_steps(1)

    #Step1 Make a Get request on {{protocol}}{{url}}/v3/ediary/entry_groups
    test_rail_expected_result(1, "User can get a 200 response and the entry group list")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/ediary/entry_groups
    ediary_entrygroups = V3::Ediary::EntryGroups::Index.new(super_user_session.token, user_email, base_url)
    test_rail_result(1, "ediary_entrygroups body header: #{ediary_entrygroups.response.headers}")
    test_rail_result(1, "ediary_entrygroups body: #{ediary_entrygroups.response.body}")
    resp_code = ediary_entrygroups.response.code
    resp_json = JSON.parse(ediary_entrygroups.response.body)
    expect(resp_code).to eq 200
    test_rail_result(1, "ediary_entrygroups response code: #{resp_code}", "pass")
    type = resp_json['data'].all? { |data| data.dig('type') == "ediary__entry_groups"}
    expect(type).to be true
    test_rail_result(1, "ediary entry groups list in response: #{type}", "pass")
  end

end


