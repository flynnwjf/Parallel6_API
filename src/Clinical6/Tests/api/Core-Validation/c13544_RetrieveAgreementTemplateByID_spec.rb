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
  let(:testname) { "agreement_templates_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"]}
  let(:template_name) { "TestTemplate" + DateTime.now.strftime('_%F_%Q').to_s }

  it 'C13544 API Client should be able to retrieve agreement templates by id', test_id: 'C13544' do
    test_rail_expected_steps(4)

    #Step1 Make a Post request on /v3/agreement/templates
    test_rail_expected_result(1, "The user should see a 200 OK status and a response with an agreement template")
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

    #Step2 Make a Get request on /v3/agreement/templates/:id
    test_rail_expected_result(2, "The user should see a 200 OK status and should see a response with that created agreement template that was created in the previous step")
    #Get request on /v3/agreement/templates/:id
    show_template = V3::Agreement::Templates::Show.new(super_user_session.token, user_email, base_url, template_id)
    test_rail_result(2, "show_template body header: #{show_template.response.headers}")
    test_rail_result(2, "show_template body: #{show_template.response.body}")
    resp_code = show_template.response.code
    resp_json = JSON.parse(show_template.response.body)
    expect(resp_code).to eq 200
    test_rail_result(2, "show_template response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'id')).to eq template_id
    test_rail_result(2, "template id contained in response: #{template_id}")

    #Step3 Make a Get request on /v3/agreement/templates/:id with invalid parameter
    test_rail_expected_result(3, "The user should see a 404 Not Found status")
    #Get request on /v3/agreement/templates/:id
    invalid_id = test_data["invalid_id"]
    show_template = V3::Agreement::Templates::Show.new(super_user_session.token, user_email, base_url, invalid_id)
    test_rail_result(3, "show_template body header: #{show_template.response.headers}")
    test_rail_result(3, "show_template body: #{show_template.response.body}")
    resp_code = show_template.response.code
    expect(resp_code).to eq 404
    test_rail_result(3, "show_template response code: #{resp_code}", "pass")

    #Step4 The unauthorized user makes a Get request on /v3/agreement/templates/:id
    test_rail_expected_result(4, "The user should see a 403 Forbidden")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on /v3/agreement/templates/:id
    show_template = V3::Agreement::Templates::Show.new(unauthorized_user_session.token, unauthorized_user_email, base_url, template_id)
    test_rail_result(4, "show_template body header: #{show_template.response.headers}")
    test_rail_result(4, "show_template body: #{show_template.response.body}")
    resp_code = show_template.response.code
    expect(resp_code).to eq 403
    test_rail_result(4, "show_template response code: #{resp_code}", "pass")
  end

end


