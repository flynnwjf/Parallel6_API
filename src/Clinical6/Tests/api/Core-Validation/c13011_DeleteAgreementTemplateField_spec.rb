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
  let(:testname) { "agreement_templatesfields_destroy" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:field_name) { test_data["field_name"] + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C13011 An Admin user should be able to delete an Agreement Template Field', test_id: 'C13011' do
    test_rail_expected_steps(4)

    #Step1 The user makes a Post request on /v3/agreement/template_fields
    test_rail_expected_result(1, "User can get 201 created response with agreement__template_fields id")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Post request on /v3/agreement/template_fields
    templates_fields_create = V3::Agreement::TemplateFields::Create.new(super_user_session.token, user_email, base_url, field_name)
    field_id = templates_fields_create.id
    resp_code = templates_fields_create.response.code
    expect(resp_code).to eq 201
    test_rail_result(1, "templates_fields_create header: #{templates_fields_create.response.headers}")
    test_rail_result(1, "templates_fields_create body: #{templates_fields_create.response.body}")
    test_rail_result(1, "templates_fields_create response code: #{resp_code}", "pass")

    #Step2 The user makes a DELETE request on {{protocol}}{{url}}/v3/agreement/template_fields/:id
    test_rail_expected_result(2, "User can get 204 No Content response")
    template_field_destroy = V3::Agreement::TemplateFields::Destroy.new(super_user_session.token, user_email, base_url, field_id)
    test_rail_result(2, "template_field_destroy header: #{template_field_destroy.response.headers}")
    test_rail_result(2, "template_field_destroy body: #{template_field_destroy.response.body}")
    resp_code = template_field_destroy.response.code
    expect(resp_code).to eq 204
    test_rail_result(2, "template_field_destroy response code: #{resp_code}", "pass")

    #Step3 The user makes a DELETE request on {{protocol}}{{url}}/v3/agreement/template_fields/:id with invalid id
    test_rail_expected_result(3, "User can get 404 Not Found response")
    invalid_id = test_data["invalid_id"]
    template_field_destroy = V3::Agreement::TemplateFields::Destroy.new(super_user_session.token, user_email, base_url, invalid_id)
    test_rail_result(3, "template_field_destroy header: #{template_field_destroy.response.headers}")
    test_rail_result(3, "template_field_destroy body: #{template_field_destroy.response.body}")
    resp_code = template_field_destroy.response.code
    expect(resp_code).to eq 404
    test_rail_result(3, "template_field_destroy response code: #{resp_code}", "pass")

    #Step4 The user makes a DELETE request on {{protocol}}{{url}}/v3/agreement/template_fields/:id
    test_rail_expected_result(4, "User can get 403 Forbidden response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    template_field_destroy = V3::Agreement::TemplateFields::Destroy.new(unauthorized_user_session.token, unauthorized_user_email, base_url, 2)
    test_rail_result(4, "template_field_destroy header: #{template_field_destroy.response.headers}")
    test_rail_result(4, "template_field_destroy body: #{template_field_destroy.response.body}")
    resp_code = template_field_destroy.response.code
    expect(resp_code).to eq 403
    test_rail_result(4, "template_field_destroy response code: #{resp_code}", "pass")
  end

end