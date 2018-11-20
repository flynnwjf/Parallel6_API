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
  let(:testname) { "consent_forms_formversions_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C13248 API Client should be able to retrieve the list of versions for a given consent form', test_id: 'C13248' do
    test_rail_expected_steps(3)

    #Step1 Make a GET request on {{protocol}}{{url}}/v3/consent/forms/{{id}}/consent/form_versions
    test_rail_expected_result(1, "The result returns a 200 response and the details for each form version")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #GET request on {{protocol}}{{url}}/v3/consent/forms/{{id}}/consent/form_versions
    form_version_id = V3::Consent::FormVersions::Index.new(super_user_session.token, user_email, base_url).id
    consent_forms_formversions_list = V3::Consent::Forms::FormVesions::List.new(super_user_session.token, user_email, base_url, form_version_id)
    resp_code = consent_forms_formversions_list.response.code
    test_rail_result(1, "consent_forms_formversions_list header: #{consent_forms_formversions_list.response.headers}")
    test_rail_result(1, "consent_forms_formversions_list body: #{consent_forms_formversions_list.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting consent forms formversions list response code: #{resp_code}", "pass")

    #Step2 Make a GET request on {{protocol}}{{url}}/v3/consent/forms/{{id}}/consent/form_versions with invalid id
    test_rail_expected_result(2, "The result returns a 404 response with the error message detail Couldn't find Consent::Form with 'id'={{id}}.")
    #GET request on {{protocol}}{{url}}/v3/consent/forms/{{id}}/consent/form_versions
    invalid_id = test_data["invalid_id"]
    consent_forms_formversions_list = V3::Consent::Forms::FormVesions::List.new(super_user_session.token, user_email, base_url, invalid_id)
    resp_code = consent_forms_formversions_list.response.code
    test_rail_result(2, "consent_forms_formversions_list header: #{consent_forms_formversions_list.response.headers}")
    test_rail_result(2, "consent_forms_formversions_list body: #{consent_forms_formversions_list.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "getting consent forms formversions list response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a GET request on {{protocol}}{{url}}/v3/consent/forms/{{id}}/consent/form_versions
    test_rail_expected_result(3, "The result returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #GET request on {{protocol}}{{url}}/v3/consent/forms/{{id}}/consent/form_versions
    consent_forms_formversions_list = V3::Consent::Forms::FormVesions::List.new(unauthorized_user_session.token, unauthorized_user_email, base_url, form_version_id)
    resp_code = consent_forms_formversions_list.response.code
    test_rail_result(3, "consent_forms_formversions_list header: #{consent_forms_formversions_list.response.headers}")
    test_rail_result(3, "consent_forms_formversions_list body: #{consent_forms_formversions_list.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "getting consent forms formversions list response code: #{resp_code}", "pass")
  end

end


