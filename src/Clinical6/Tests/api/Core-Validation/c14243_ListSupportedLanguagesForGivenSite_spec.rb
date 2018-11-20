require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:testname) { "trials_sites_sitesupportedlanguages_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C14243 Site should be able to ensure that the content that the patients see is in a language that he can support', test_id: 'C14243' do
    test_rail_expected_steps(2)

    #Step1 The user makes a Get request on /v3/trials/sites/:site_id/trials/site_supported_languages with valid site id
    test_rail_expected_result(1, "User can get 200 response and list Site Supported Languages for a given Site")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on /v3/trials/sites/:site_id/trials/site_supported_languages with valid site id
    site_id = V3::Trials::Sites::List.new(super_user_session.token, user_email, base_url).id
    support_language = V3::Trials::Sites::SiteSupportedLanguages::List.new(super_user_session.token, user_email, base_url, site_id)
    resp_code = support_language.response.code
    resp_json = JSON.parse(support_language.response.body)
    test_rail_result(1, "support_language header: #{support_language.response.headers}")
    test_rail_result(1, "support_language body: #{support_language.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "list of supported language response code: #{resp_code}", "pass")
    language_id = resp_json['data'].all? { |iso| iso.dig('id') != nil}
    language = resp_json['data'].all? { |iso| iso.dig('type') == "trials__site_supported_languages"}
    expect(language_id).to be true
    expect(language).to be true
    test_rail_result(1, "language id(s) in response: #{language_id}", "pass")
    test_rail_result(1, "language list in response: #{language}", "pass")

    #Step2 The user makes a Get request on /v3/trials/sites/:site_id/trials/site_supported_languages with invalid site id
    test_rail_expected_result(2, "User can get 404 Record Not Found")
    #Get request on /v3/trials/sites/:site_id/trials/site_supported_languages with valid site id
    invalid_id = test_data["invalid_id"]
    support_language = V3::Trials::Sites::SiteSupportedLanguages::List.new(super_user_session.token, user_email, base_url, invalid_id)
    resp_code = support_language.response.code
    test_rail_result(2, "support_language header: #{support_language.response.headers}")
    test_rail_result(2, "support_language body: #{support_language.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "list of supported language response code: #{resp_code}", "pass")
  end

end

