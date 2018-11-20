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
  let(:testname) { "agreement_templatesfields_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:field_name) { "TestField" + Time.new.strftime("%Y%m%d%H%M%S") }

  it 'C12863 Admin user should be able to add new Fields to an existing Agreement Template', test_id: 'C12863' do
    test_rail_expected_steps(3)

    #Step1 The user makes a GET request on {{protocol}}{{url}}/v3/agreement/templates/
    test_rail_expected_result(1, "The response is 200 OK, identify the Agreement template to be edited")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    templates = V3::Agreement::Templates::List.new(super_user_session.token, user_email, base_url)
    test_rail_result(1, "templates_list header: #{templates.response.headers}")
    test_rail_result(1, "templates_list body: #{templates.response.body}")
    #resp_json = JSON.parse(templates.response.body)
    expect(templates.response.code).to eq 200
    test_rail_result(1, "list of agreement templates response code: #{templates.response.code}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/agreement/template_fields
    test_rail_expected_result(2, "A response is generated. The Status: 201 Created, and the Body includes the newly created field")
    template_fields = V3::Agreement::TemplateFields::Create.new(super_user_session.token, user_email, base_url, field_name)
    test_rail_result(2, "template_fields header: #{template_fields.response.headers}")
    test_rail_result(2, "template_fields body: #{template_fields.response.body}")
    resp_json = JSON.parse(template_fields.response.body)
    expect(template_fields.response.code).to eq 201
    test_rail_result(2, "creating new field response code: #{template_fields.response.code}")
    id = resp_json.dig('data', 'id')
    expect(id).not_to eq nil
    test_rail_result(2, "id(s) contained in response: #{id}")
    expect(resp_json.dig('data', 'type')).to eq "agreement__template_fields"
    test_rail_result(2, "agreement__template_fields was contained in data")
    expect(resp_json.dig('data', 'attributes', 'field_name')).to eq field_name
    test_rail_result(2, "#{field_name} was found in data", "pass")

    #Step3 The unauthorized user makes a POST request on {{protocol}}{{url}}/v3/agreement/template_fields
    test_rail_expected_result(3, "It returns 403 Forbidden")
    env_user = DataHandler.get_env_user(env_info, :unauthorized_user)
    user_email = env_user["email"]
    user_password = env_user["password"]
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(3, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(3, "Super User session body: #{super_user_session.response.body}")
    template_fields = V3::Agreement::TemplateFields::Create.new(super_user_session.token, user_email, base_url, field_name)
    test_rail_result(3, "template_fields header: #{template_fields.response.headers}")
    test_rail_result(3, "template_fields body: #{template_fields.response.body}")
    expect(template_fields.response.code).to eq 403
    test_rail_result(3, "creating new field response code: #{template_fields.response.code}", "pass")
  end
end




