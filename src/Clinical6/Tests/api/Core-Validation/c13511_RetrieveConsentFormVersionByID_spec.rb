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
  let(:testname) { "consent_formversions_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C13511 API Client should be able to retrieve a Consent::FormVersion by ID', test_id: 'C13511' do
    test_rail_expected_steps(4)

    #Step1 Make a Post request on {{protocol}}{{url}}/v3/consent/form_versions
    test_rail_expected_result(1, "User receive a 201 Created and a Consent version form")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/consent/form_versions
    temp_id = V3::Agreement::Templates::List.new(super_user_session.token, user_email, base_url).id
    site_id = V3::Trials::Sites::List.new(super_user_session.token, user_email, base_url).id
    form_id = V3::Consent::Forms::Index.new(super_user_session.token, user_email, base_url).id
    language_id = V3::Languages::Index.new(super_user_session.token, user_email, base_url).id
    form_versions = V3::Consent::FormVersions::Create.new(super_user_session.token, user_email, base_url, temp_id, site_id, form_id, language_id)
    test_rail_result(1, "form_versions body header: #{form_versions.response.headers}")
    test_rail_result(1, "form_versions body: #{form_versions.response.body}")
    resp_code = form_versions.response.code
    resp_json = JSON.parse(form_versions.response.body)
    expect(resp_code).to eq 201
    test_rail_result(1, "form_versions response code: #{resp_code}", "pass")
    version_id = form_versions.id

    #Step2 Make a Get request on {{protocol}}{{url}}v3/consent/form_versions/{{id}}
    test_rail_expected_result(2, "User should receive a 200 OK status and should see the Consent version form that the user created")
    #Get request on {{protocol}}{{url}}/v3/consent/form_versions/{{id}}
    consent_form_versions = V3::Consent::FormVersions::Show.new(super_user_session.token, user_email, base_url, version_id)
    test_rail_result(2, "consent_form_versions body header: #{consent_form_versions.response.headers}")
    test_rail_result(2, "consent_form_versions body: #{consent_form_versions.response.body}")
    resp_code = consent_form_versions.response.code
    resp_json = JSON.parse(consent_form_versions.response.body)
    expect(resp_code).to eq 200
    test_rail_result(2, "consent_form_versions response code: #{resp_code}", "pass")
    expect(resp_json.dig("data", "id")).to eq version_id
    test_rail_result(2, "created form version id in response: #{version_id}", "pass")

    #Step3 Make a Get request on {{protocol}}{{url}}v3/consent/form_versions/{{id}} with invalid id
    test_rail_expected_result(3, "User should receive a 404 Not Found")
    #Get request on {{protocol}}{{url}}/v3/consent/form_versions/{{id}}
    invalid_id = test_data["invalid_id"]
    consent_form_versions = V3::Consent::FormVersions::Show.new(super_user_session.token, user_email, base_url, invalid_id)
    test_rail_result(3, "consent_form_versions body header: #{consent_form_versions.response.headers}")
    test_rail_result(3, "consent_form_versions body: #{consent_form_versions.response.body}")
    resp_code = consent_form_versions.response.code
    expect(resp_code).to eq 404
    test_rail_result(3, "consent_form_versions response code: #{resp_code}", "pass")

    #Step4 The unauthorized user makes a Get request on {{protocol}}{{url}}/v3/consent/form_versions/{{id}}
    test_rail_expected_result(4, "User should receive a 403 Forbidden")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/consent/form_versions/{{id}}
    consent_form_versions = V3::Consent::FormVersions::Show.new(unauthorized_user_session.token, unauthorized_user_email, base_url, version_id)
    test_rail_result(4, "consent_form_versions body header: #{consent_form_versions.response.headers}")
    test_rail_result(4, "consent_form_versions body: #{consent_form_versions.response.body}")
    resp_code = consent_form_versions.response.code
    expect(resp_code).to eq 403
    test_rail_result(4, "consent_form_versions response code: #{resp_code}", "pass")
  end

end


