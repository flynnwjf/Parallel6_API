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
  let(:testname) { "datacollection_capturedvaluegroups_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }


  it 'C14646 The System Administrator should be able to retrieve the profile associated with a mobile user', test_id: 'C14646' do
    test_rail_expected_steps(3)


    #Step1 The user makes a GET request for /v3/data_collection/captured_value_groups
    test_rail_expected_result(1, "User observes that the captured values group is not final")
    new_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "new_session header: #{new_session.response.headers}")
    test_rail_result(1, "new_session body: #{new_session.response.body}")
    expect(new_session.response.code).to eq 201
    dc_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Update.new(new_session.token, user_email, base_url, id, false)
    mobile_user_id = JSON.parse(dc_capturedvaluegroups.response.body).dig("data", "relationships", "owner", "data", "id")
    #puts "hi #{dc_capturedvaluegroups.response.body}"
    group_id = JSON.parse(dc_capturedvaluegroups.response.body).dig("data", "id")
    dc_capturedvaluegroups_show = V3::DataCollection::CapturedValueGroups::Show.new(new_session.token, user_email, base_url, mobile_user_id, group_id)
    test_rail_result(1, "dc_capturedvaluegroups_show header: #{dc_capturedvaluegroups_show.response.headers}")
    test_rail_result(1, "dc_capturedvaluegroups_show body: #{dc_capturedvaluegroups_show.response.body}")
    expect(dc_capturedvaluegroups_show.response.code).to eq 200
    final_submission = JSON.parse(dc_capturedvaluegroups_show.response.body).dig('data', 'attributes', 'final_submission')
    expect(final_submission).to eq false
    test_rail_result(1, "dc_capturedvaluegroups_show response code: #{dc_capturedvaluegroups_show.response.code}")
    test_rail_result(1, "final submission:  #{final_submission}", "pass")


    #Step2 The user makes a PATCH request for /v3/data_collection/captured_value_groups/:captured_value_group_id
    test_rail_expected_result(2, "User observes that the captured values group is not final")
    test_rail_result(2, "dc_capturedvaluegroups_show header: #{dc_capturedvaluegroups_show.response.headers}")
    test_rail_result(2, "dc_capturedvaluegroups_show body: #{dc_capturedvaluegroups_show.response.body}")
    dc_capturedvaluegroups = V3::DataCollection::CapturedValueGroups::Update.new(new_session.token, user_email, base_url, id, true)
    test_rail_result(2, "dc_capturedvaluegroups header: #{dc_capturedvaluegroups.response.headers}")
    test_rail_result(2, "dc_capturedvaluegroups body: #{dc_capturedvaluegroups.response.body}")
    expect(dc_capturedvaluegroups.response.code).to eq 200
    test_rail_result(2, "dc_capturedvaluegroups response code: #{dc_capturedvaluegroups.response.code}", "pass")

    #Step3 The user makes a GET request for /v3/data_collection/captured_value_groups
    test_rail_expected_result(3, "All captured data is displayed, and the user is able
              to view the updated value of the final_submission related to the associated captured_value_group_id is FINAL")
    dc_capturedvaluegroups_show = V3::DataCollection::CapturedValueGroups::Show.new(new_session.token, user_email, base_url, mobile_user_id, group_id)
    test_rail_result(3, "dc_capturedvaluegroups_show header: #{dc_capturedvaluegroups_show.response.headers}")
    test_rail_result(3, "dc_capturedvaluegroups_show body: #{dc_capturedvaluegroups_show.response.body}")
    expect(dc_capturedvaluegroups_show.response.code).to eq 200
    final_submission = JSON.parse(dc_capturedvaluegroups_show.response.body).dig('data', 'attributes', 'final_submission')
    expect(final_submission).to eq true
    test_rail_result(3, "dc_capturedvaluegroups_show response code: #{dc_capturedvaluegroups_show.response.code}")
    test_rail_result(3, "final submission:  #{final_submission}", "pass")

  end
end


