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


  it 'C14247 System allows to view a pre-defined email of a site', test_id: 'C14247' do
    test_rail_expected_steps(1)

    #Step1 The user makes a Get request on /v3/trials/sites
    test_rail_expected_result(1, "Returns a 200 response with the list of existing sites.")
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
    test_rail_result(1, "list of existing sites and contact_email response code: #{resp_code}", "pass")
    email = resp_json['data'].any? { |email| email.dig('attributes', 'email').is_a? String}
    contact_email = resp_json['data'].any? { |email| email.dig('attributes', 'contact_email').is_a? String}
    expect(email).to be true
    expect(contact_email).to be true
    test_rail_result(1, "email in response: #{email}", "pass")
    test_rail_result(1, "contact_email in response: #{contact_email}", "pass")
  end

end

