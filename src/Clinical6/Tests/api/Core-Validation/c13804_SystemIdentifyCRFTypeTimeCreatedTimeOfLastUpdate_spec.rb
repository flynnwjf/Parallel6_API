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
  let(:testname) { "datacollection_capturedvaluegroups_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C13804 The system should identify the creator, CRF type, time created, and time of last update, for each CRF', test_id: 'C13804' do
    test_rail_expected_steps(2)

    #Step1 <user1> Makes a GET request on {{protocol}}{{url}}/v3/data_collection/captured_value_groups
    test_rail_expected_result(1, "Captured value groups are displayed with Creator, Type, time created, time updated")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")


    datacollection_capturedvaluegroups_index = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    test_rail_result(1, "datacollection_capturedvaluegroups_index header: #{datacollection_capturedvaluegroups_index.response.headers}")
    test_rail_result(1, "datacollection_capturedvaluegroups_index body: #{datacollection_capturedvaluegroups_index.response.body}")
    expect(datacollection_capturedvaluegroups_index.response.code).to eq 200
    #expect(JSON.parse(datacollection_capturedvaluegroups_index.response.body).dig('data', 0, 'id')).not_to eq ""
    creator_id = JSON.parse(datacollection_capturedvaluegroups_index.response.body).dig('data', 0, 'relationships', 'creator', 'data', 'id')
    crf_type = JSON.parse(datacollection_capturedvaluegroups_index.response.body).dig('data', 0, 'type')
    created_at = JSON.parse(datacollection_capturedvaluegroups_index.response.body).dig('data', 0, 'attributes', 'created_at')
    updated_at = JSON.parse(datacollection_capturedvaluegroups_index.response.body).dig('data', 0, 'attributes', 'updated_at')
    expect(creator_id).to_not be nil
    expect(crf_type).to eq "data_collection__captured_value_groups"
    expect(created_at).to_not be nil
    expect(updated_at).to_not be nil
    test_rail_result(1, "expected values were present: true", "pass")


    #Step2 <user2> Makes a GET request on {{protocol}}{{url}}/v3/data_collection/captured_value_groups
    test_rail_expected_result(2, "403 status code")

    env_user = DataHandler.get_env_user(env_info, :unauthorized_user)
    user_email = env_user["email"]
    user_password = env_user["password"]

    #Step1 <user1> Makes a GET request on {{protocol}}{{url}}/v3/data_collection/captured_value_groups
    test_rail_expected_result(2, "Captured value groups are displayed with Creator, Type, time created, time updated")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(2, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(2, "Super User session body: #{super_user_session.response.body}")


    datacollection_capturedvaluegroups_index = V3::DataCollection::CapturedValueGroups::Index.new(super_user_session.token, user_email, base_url)
    test_rail_result(2, "datacollection_capturedvaluegroups_index header: #{datacollection_capturedvaluegroups_index.response.headers}")
    test_rail_result(2, "datacollection_capturedvaluegroups_index body: #{datacollection_capturedvaluegroups_index.response.body}")
    expect(datacollection_capturedvaluegroups_index.response.code).to eq 403
    test_rail_result(2, "datacollection_capturedvaluegroups_index response code: #{datacollection_capturedvaluegroups_index.response.code}", "pass")
  end

end

