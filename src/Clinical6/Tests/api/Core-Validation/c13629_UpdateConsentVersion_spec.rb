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
  let(:testname) { "consent_approver_groups_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test-" + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C13629 API Client should be able to update a Consent Version', test_id: 'C13629' do
    test_rail_expected_steps(5)

    #Step1 The user makes a GET request on /v3/consent/form_versions
    test_rail_expected_result(1, "The list of form_versions are displayed in the response, Identify the value of form_version_id to be updated")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #GET request on /v3/consent/form_versions
    consent_formversions_index = V3::Consent::FormVersions::Index.new(super_user_session.token, user_email, base_url)
    version_id = consent_formversions_index.id
    resp_code = consent_formversions_index.response.code
    resp_json = JSON.parse(consent_formversions_index.response.body)
    test_rail_result(1, "consent_formversions_index header: #{consent_formversions_index.response.headers}")
    test_rail_result(1, "consent_formversions_index body: #{consent_formversions_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting consent form versions response code: #{resp_code}", "pass")

    #Step2 The user makes a PATCH request on {{protocol}}{{url}}/v3/consent/form_versions/{id}
    test_rail_expected_result(2, "User should receive a 201 status with the updated form version in the response")
    #PATCH request on {{protocol}}{{url}}/v3/consent/form_versions/{id}
    agreement_template_id = V3::Agreement::Templates::List.new(super_user_session.token, user_email, base_url).id
    consent_formversions_update = V3::Consent::FormVersions::Update.new(super_user_session.token, user_email, base_url, version_id, agreement_template_id)
    resp_code = consent_formversions_update.response.code
    test_rail_result(2, "consent_formversions_update header: #{consent_formversions_update.response.headers}")
    test_rail_result(2, "consent_formversions_update body: #{consent_formversions_update.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(2, "updating consent form version response code: #{resp_code}", "pass")

    #Step3 The user makes a PATCH request on {{protocol}}{{url}}/v3/consent/form_versions/{id} with invalid parameter
    test_rail_expected_result(3, "User should receive a 422 Unprocessable Entry status")
    #PATCH request on {{protocol}}{{url}}/v3/consent/form_versions/{id}
    invalid_template = test_data["invalid_id"]
    consent_formversions_update = V3::Consent::FormVersions::Update.new(super_user_session.token, user_email, base_url, version_id, invalid_template)
    resp_code = consent_formversions_update.response.code
    test_rail_result(3, "consent_formversions_update header: #{consent_formversions_update.response.headers}")
    test_rail_result(3, "consent_formversions_update body: #{consent_formversions_update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(3, "updating consent form version response code: #{resp_code}", "pass")

    #Step4 The user makes a PATCH request on {{protocol}}{{url}}/v3/consent/form_versions/{id} with invalid id
    test_rail_expected_result(4, "User should receive a 404 Not Found status")
    #PATCH request on {{protocol}}{{url}}/v3/consent/form_versions/{id}
    invalid_id = test_data["invalid_id"]
    consent_formversions_update = V3::Consent::FormVersions::Update.new(super_user_session.token, user_email, base_url, invalid_id, agreement_template_id)
    resp_code = consent_formversions_update.response.code
    test_rail_result(4, "consent_formversions_update header: #{consent_formversions_update.response.headers}")
    test_rail_result(4, "consent_formversions_update body: #{consent_formversions_update.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(4, "updating consent form version response code: #{resp_code}", "pass")

    #Step5 The unauthorized user makes a PATCH request on {{protocol}}{{url}}/v3/consent/form_versions/{id}
    test_rail_expected_result(5, "User should receive a 403 Forbidden status")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(5, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(5, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #PATCH request on {{protocol}}{{url}}/v3/consent/form_versions/{id}
    consent_formversions_update = V3::Consent::FormVersions::Update.new(unauthorized_user_session.token, unauthorized_user_email, base_url, version_id, agreement_template_id)
    resp_code = consent_formversions_update.response.code
    test_rail_result(5, "consent_formversions_update header: #{consent_formversions_update.response.headers}")
    test_rail_result(5, "consent_formversions_update body: #{consent_formversions_update.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(5, "updating consent form version response code: #{resp_code}", "pass")
  end

end

