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
  let(:testname) { "agreement_templates_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C12768 - Admin user should able to retrieve all Agreement Templates available in the system so that they can review and manage them', test_id: 'C12768' do
    test_rail_expected_steps(1)

    #Step1 Make a Get request on /v3/agreement/templates
    test_rail_expected_result(1, "It returns 200 response and displays a list of agreement templates with their id, type, attributes, etc.")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    templates = V3::Agreement::Templates::List.new(super_user_session.token, user_email, base_url)
    test_rail_result(1, "templates body header: #{templates.response.headers}")
    test_rail_result(1, "templates body: #{templates.response.body}")
    resp_code = templates.response.code
    resp_json = JSON.parse(templates.response.body)
    expect(resp_code).to eq 200
    test_rail_result(1, "templates response code: #{templates.response.code}")
    id = resp_json['data'].all? { |templates| templates.dig('id') != nil }
    type = resp_json['data'].all? { |templates| templates.dig('type') == 'agreement__templates' }
    expect(id).to be true
    expect(type).to be true
    test_rail_result(1, "id(s) contained in response: #{id}")
    test_rail_result(1, "type(s) contained in response: #{type}", "pass")
      # resp_json['data'].each { |templates| puts templates.dig('id') }
  end

end


