require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:env_mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { env_mobile_user["email"] }
  let(:mobile_user_password) { env_mobile_user["password"] }
  let(:device_id) { env_mobile_user["device_id"] }
#Test Info
  let(:testname) { "mobileuser_ediary_entries_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
#  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
#let(:id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id}


  it 'C14299 Users should be able to view the status of each eDiary section for a given date', test_id: 'C14299' do
    test_rail_expected_steps(2)

    #Step1 Make a Post request on /v3/mobile_users/sessions
    test_rail_expected_result(1, "User can get mobile user id")
    new_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "new_session header: #{new_session.response.headers}")
    test_rail_result(1, "new_session body: #{new_session.response.body}")
    expect(new_session.response.code).to eq 201

    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    test_rail_result(1, "Mobile User id: #{mobile_user_session.mobile_user_id}", "pass")

    #Step1 Make a Post request on /v3/mobile_users/sessions
    test_rail_expected_result(2, "200 response and entries contain the status.")
    mobileuser_ediary_entries_show = V3::MobileUser::Ediary::Entries::Show.new(new_session.token, user_email, base_url, mobile_user_session.mobile_user_id)
    test_rail_result(2, "mobileuser_ediary_entries_show header: #{mobileuser_ediary_entries_show.response.headers}")
    test_rail_result(2, "mobileuser_ediary_entries_show body: #{mobileuser_ediary_entries_show.response.body}")
    expect(mobileuser_ediary_entries_show.response.code).to eq 200
    status = JSON.parse(mobileuser_ediary_entries_show.response.body).dig('data', 0, 'relationships', 'status')
    expect(status).to_not be nil
    test_rail_result(2, "status field was present", "pass")
  end
end


