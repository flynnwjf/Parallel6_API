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

  it 'C12567 V3 endpoints relationship to Users should be added', test_id: 'C12567' do
    test_rail_expected_steps(1)

    #Step1 Make a Get request on /v3/mobile_users/:mobile_user_id/related_users?filter
    test_rail_expected_result(1, "User can get list of all Related Users of a given Mobile User according to the filter")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "super_user_session header: #{super_user_session.response.headers}")
    test_rail_result(1, "super_user_session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id)
    test_rail_result(1, "mobile_user_session header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "mobile_user_session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #Get request on /v3/mobile_users/:mobile_user_id/related_users?filter
    mobileuser_relatedusers = V3::MobileUser::RelatedUsers::Show.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_relatedusers.response_filter.code
    resp_json = JSON.parse(mobileuser_relatedusers.response_filter.body)
    test_rail_result(1, "mobileuser_relatedusers header: #{mobileuser_relatedusers.response.headers}")
    test_rail_result(1, "mobileuser_relatedusers body: #{mobileuser_relatedusers.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting mobile user related users response code: #{resp_code}", "pass")
    id = resp_json['data'].all?{|data|data.dig('id') != nil}
    type = resp_json['data'].all?{|data|data.dig('type') == "related_users"}
    expect(id).to be true
    expect(type).to be true
    test_rail_result(1, "ids are in response: #{id}", "pass")
    test_rail_result(1, "types are in response: #{type}", "pass")
  end

end


