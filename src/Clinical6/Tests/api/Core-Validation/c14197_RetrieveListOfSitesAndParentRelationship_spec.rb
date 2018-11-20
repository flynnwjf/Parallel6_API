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
  let(:testname) { "trials_sites_sitemembers_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C14197 The system shall support a list of Sites and the parent-child relationship among them', test_id: 'C14197' do
    test_rail_expected_steps(2)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/users/session
    test_rail_expected_result(1, "New session created for superuser with new authentication token")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    resp_code = super_user_session.response.code
    expect(resp_code).to eq 201
    test_rail_result(1, "creating user session response code: #{resp_code}", "pass")

    #Step2 The user makes a Get request on {{protocol}}{{url}}/v3/trials/sites/1/trials/site_members
    test_rail_expected_result(2, "New session created for superuser with new authentication token")
    #Get request on {{protocol}}{{url}}/v3/trials/sites/1/trials/site_members
    site_id = V3::Trials::Sites::List.new(super_user_session.token, user_email, base_url).id
    site_members = V3::Trials::Sites::SiteMembers::Index.new(super_user_session.token, user_email, base_url, site_id)
    resp_code = site_members.response.code
    resp_json = JSON.parse(site_members.response.body)
    expect(resp_code).to eq 200
    test_rail_result(2, "getting site member for a site response code: #{resp_code}", "pass")
    id = resp_json['data'].all? { |data| data.dig('id') != nil }
    type = resp_json['data'].all? { |data| data.dig('type') == "trials__site_members" }
    expect(id).to be true
    expect(type).to be true
    test_rail_result(2, "id(s) contained in response: #{id}", "pass")
    test_rail_result(2, "type(s) contained in response: #{type}", "pass")
  end

end

