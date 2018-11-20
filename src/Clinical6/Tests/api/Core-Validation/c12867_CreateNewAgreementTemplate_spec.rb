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
  let(:testname) { "agreement_templates_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:template_name) { test_data["template_name"] + DateTime.now.strftime('_%F_%Q').to_s }


  it 'C12867 User should be able to create a new agreement template', test_id: 'C12867' do
    test_rail_expected_steps(3)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/agreement/templates
    test_rail_expected_result(1, "It returns 201 and new agreement template is created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/agreement/templates
    agreement_template = V3::Agreement::Templates::Create.new(super_user_session.token, user_email, base_url, type, template_name)
    resp_code = agreement_template.response.code
    resp_json = JSON.parse(agreement_template.response.body)
    test_rail_result(1, "agreement_template header: #{agreement_template.response.headers}")
    test_rail_result(1, "agreement_template body: #{agreement_template.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "creating agreement template response code: #{resp_code}", "pass")
    template_id = resp_json.dig('data', 'id')
    expect(template_id).not_to eq nil
    test_rail_result(1, "created template id in response: #{template_id}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/agreement/templates with invalid parameters
    test_rail_expected_result(2, "It returns 422 Unprocessable Entity and the agreement template is not created")
    #POST request on {{protocol}}{{url}}/v3/agreement/templates with invalid parameters
    invalid_name = test_data["invalid_template_name"]
    agreement_template = V3::Agreement::Templates::Create.new(super_user_session.token, user_email, base_url, type, invalid_name)
    resp_code = agreement_template.response.code
    test_rail_result(2, "agreement_template header: #{agreement_template.response.headers}")
    test_rail_result(2, "agreement_template body: #{agreement_template.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(2, "creating agreement template with invalid parameters response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a post request on {{protocol}}{{url}}/v3/agreement/templates
    test_rail_expected_result(3, "User should receive a 403 status (Forbidden)")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/agreement/templates
    agreement_template = V3::Agreement::Templates::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, type, template_name)
    resp_code = agreement_template.response.code
    test_rail_result(3, "agreement_template header: #{agreement_template.response.headers}")
    test_rail_result(3, "agreement_template body: #{agreement_template.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "creating agreement template response code: #{resp_code}", "pass")
  end

end

