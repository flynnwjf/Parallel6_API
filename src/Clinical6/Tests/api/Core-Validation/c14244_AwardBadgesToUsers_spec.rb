require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_email) { mobile_user["email"] }
  let(:mobile_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:testname) { "badges_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] }
  let(:description) { test_data["description"] }


  it 'C14244 System awards badges to users', test_id: 'C14244' do
    test_rail_expected_steps(3)

    #Step1 Make a POST request on {{protocol}}{{url}}/v3/badges
    test_rail_expected_result(1, "The user can get 201 Created response and badge id")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/badges
    badge = V3::Badges::Create.new(super_user_session.token, user_email, base_url, type, title, description)
    badge_id = badge.id
    resp_code = badge.response.code
    test_rail_result(1, "badge header: #{badge.response.headers}")
    test_rail_result(1, "badge body: #{badge.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating badge response code: #{resp_code}", "pass")

    #Step2 Make a POST on {{protocol}}{{url}}//v3/mobile_users/{{mobile_user_id}}/badges
    test_rail_expected_result(2, "Badge should be assigned to patient")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(2, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(2, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #POST on {{protocol}}{{url}}//v3/mobile_users/{{mobile_user_id}}/badges
    user_badge = V3::MobileUser::Badges::Create.new(super_user_session.token, user_email, base_url, type, mobile_user_id, badge_id)
    resp_code = user_badge.response.code
    resp_json = JSON.parse(user_badge.response)
    test_rail_result(2, "user_badge header: #{user_badge.response.headers}")
    test_rail_result(2, "user_badge body: #{user_badge.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(2, "assign badge to mobile user response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'relationships', 'badge', 'data', 'id')).to eq badge_id
    test_rail_result(2, "badge id is associated with mobile user in response", "pass")

    #Step3 The user makes a GET request on {{protocol}}{url}}//v3/mobile_users/{{mobile_user_id}}/badges
    test_rail_expected_result(3, "Awarded badges to patient are displayed")
    #GET request on {{protocol}}{url}}//v3/mobile_users/{{mobile_user_id}}/badges
    list = V3::MobileUser::Badges::List.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = list.response.code
    resp_json = JSON.parse(list.response)
    test_rail_result(3, "list header: #{list.response.headers}")
    test_rail_result(3, "list body: #{list.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "listing all the badges associated with a mobile user response code: #{resp_code}", "pass")
    find_id = resp_json['data'].any? { |id| id.dig('relationships', 'badge', 'data', 'id') == "#{badge_id}" }
    expect(find_id).to be true
    test_rail_result(3, "the badges associated in response: #{find_id}", "pass")
  end

end


