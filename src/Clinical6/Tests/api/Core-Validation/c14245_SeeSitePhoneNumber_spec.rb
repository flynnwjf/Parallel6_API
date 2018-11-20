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
  let(:testname) { "trials_sites_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C14245 System allows users to see the phone number associated with a site', test_id: 'C14245' do
    test_rail_expected_steps(1)

    #Step1 The user makes a Get request on /v3/trials/sites
    test_rail_expected_result(1, "User can get 200 response with the list of existing sites and contact_phone can be found in attribute")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on /v3/trials/sites
    trials_sites = V3::Trials::Sites::List.new(super_user_session.token, user_email, base_url)
    resp_code = trials_sites.response.code
    resp_json = JSON.parse(trials_sites.response.body)
    test_rail_result(1, "trials_sites header: #{trials_sites.response.headers}")
    test_rail_result(1, "trials_sites body: #{trials_sites.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "list of existing sites and contact_phone response code: #{resp_code}", "pass")
    contact_phone = resp_json['data'].any? { |phone| phone.dig('attributes', 'contact_phone').is_a? String}
    expect(contact_phone).to be true
    test_rail_result(1, "contact_phone in response: #{contact_phone}", "pass")
  end

end

