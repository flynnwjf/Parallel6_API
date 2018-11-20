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
  let(:testname) { "consent_forms_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "TestForm-" + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C13479 API Client should be able to update a Consent Form', test_id: 'C13479' do
    test_rail_expected_steps(5)

    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/consent/forms
    test_rail_expected_result(1, "The result returns a 201 response and returns details of the consent form.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on {{protocol}}{{url}}/v3/consent/forms
    strategy_id = V3::Consent::Strategies::Index.new(super_user_session.token, user_email, base_url).id
    consent_forms_create = V3::Consent::Forms::Create.new(super_user_session.token, user_email, base_url, strategy_id, name)
    resp_code = consent_forms_create.response.code
    resp_json = JSON.parse(consent_forms_create.response.body)
    test_rail_result(1, "consent_forms_create header: #{consent_forms_create.response.headers}")
    test_rail_result(1, "consent_forms_create body: #{consent_forms_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating consent form response code: #{resp_code}", "pass")
    form_id = resp_json.dig("data", "id")
    expect(form_id).not_to eq nil
    expect(resp_json.dig("data", "attributes", "name")).to eq name
    test_rail_result(1, "creating consent form id and name in response: #{form_id} - #{name}", "pass")

    #Step2 The user makes a Post request on {{protocol}}{{url}}/v3/consent/forms with invalid name
    test_rail_expected_result(2, "REST Tool returns a 422 response with the error message detail can't be blank.")
    #Post request on {{protocol}}{{url}}/v3/consent/forms
    invalid_name = ""
    consent_forms_create = V3::Consent::Forms::Create.new(super_user_session.token, user_email, base_url, strategy_id, invalid_name)
    resp_code = consent_forms_create.response.code
    test_rail_result(2, "consent_forms_create header: #{consent_forms_create.response.headers}")
    test_rail_result(2, "consent_forms_create body: #{consent_forms_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating consent form response code: #{resp_code}", "pass")

    #Step3 The user makes a Post request on {{protocol}}{{url}}/v3/consent/forms with same name
    test_rail_expected_result(3, "REST Tool returns a 422 response with the error message detail has already been taken.")
    #Post request on {{protocol}}{{url}}/v3/consent/forms
    existing_name = JSON.parse(V3::Consent::Forms::Index.new(super_user_session.token, user_email, base_url).response.body).dig("data", 0, "attributes", "name")
    test_rail_result(3, "existing name is: #{existing_name}")
    consent_forms_create = V3::Consent::Forms::Create.new(super_user_session.token, user_email, base_url, strategy_id, existing_name)
    resp_code = consent_forms_create.response.code
    test_rail_result(3, "consent_forms_create header: #{consent_forms_create.response.headers}")
    test_rail_result(3, "consent_forms_create body: #{consent_forms_create.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(3, "creating consent form response code: #{resp_code}", "pass")

    #Step4 The user makes a Post request on {{protocol}}{{url}}/v3/consent/forms with long name
    test_rail_expected_result(4, "REST Tool returns a 500 error.")
    #Post request on {{protocol}}{{url}}/v3/consent/forms
    long_name = "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
    consent_forms_create = V3::Consent::Forms::Create.new(super_user_session.token, user_email, base_url, strategy_id, long_name)
    resp_code = consent_forms_create.response.code
    test_rail_result(4, "consent_forms_create header: #{consent_forms_create.response.headers}")
    test_rail_result(4, "consent_forms_create body: #{consent_forms_create.response.body}")
    expect(resp_code).to eq 500
    test_rail_result(4, "creating consent form response code: #{resp_code}", "pass")

    #Step5 The user makes a Get request on {{protocol}}{{url}}/v3/consent/forms
    test_rail_expected_result(5, "REST Tool returns a 200 response and lists the existing consent forms.")
    #Get request on {{protocol}}{{url}}/v3/consent/forms
    form_index = V3::Consent::Forms::Index.new(super_user_session.token, user_email, base_url)
    resp_code = form_index.response.code
    resp_json = JSON.parse(form_index.response.body)
    test_rail_result(5, "form_index header: #{form_index.response.headers}")
    test_rail_result(5, "form_index body: #{form_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(5, "getting consent form response code: #{resp_code}", "pass")
    created_id = resp_json['data'].any? { |n| n.dig('id') == form_id}
    expect(created_id).to be true
    test_rail_result(5, "getting created consent form name in response: #{created_id}", "pass")
  end

end

