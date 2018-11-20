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
  let(:testname) { "ediary_entrygroups_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C13827 Allows user to view a list of all eDiary surveys ever completed', test_id: 'C13827' do
    test_rail_expected_steps(1)

    #Step1 Make a Get request on /v3/ediary/entry_groups
    test_rail_expected_result(1, "User can get 200 OK response and retrieve ediary entry_groups")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on /v3/ediary/entry_groups
    ediary_entrygroups_index = V3::Ediary::EntryGroups::Index.new(super_user_session.token, user_email, base_url)
    resp_code = ediary_entrygroups_index.response.code
    resp_json = JSON.parse(ediary_entrygroups_index.response.body)
    test_rail_result(1, "ediary_entrygroups_index header: #{ediary_entrygroups_index.response.headers}")
    test_rail_result(1, "ediary_entrygroups_index body: #{ediary_entrygroups_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting ediary entry groups response code: #{resp_code}", "pass")
    if (!resp_json.dig('data', 0, 'id').eql? nil) & (resp_json.dig('data', 1, 'id').eql? nil)
      expect (resp_json.dig('data', 0, 'id').to_i > resp_json.dig('data', 1, 'id')).to be true
    end
    test_rail_result(1, "ediary entry groups are grouped by top level", "pass")
  end

end


