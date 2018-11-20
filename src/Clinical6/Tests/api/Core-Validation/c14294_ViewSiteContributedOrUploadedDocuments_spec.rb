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
  let(:testname) { "agreement_templates_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:template_name) { test_data["template_name"] + DateTime.now.strftime('_%F_%Q').to_s }

  it 'C14294 Users should be able to view site contributed/uploaded documents.', test_id: 'C14294' do
    test_rail_expected_steps(4)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/users/sessions
    test_rail_expected_result(1, "The user's session is created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    resp_code = super_user_session.response.code
    expect(resp_code).to eq 201
    test_rail_result(1, "creating user session response code: #{resp_code}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/agreement/templates
    test_rail_expected_result(2, "User should sSee the created agreement template displayed in the response with an id")
    #POST request on {{protocol}}{{url}}/v3/agreement/templates
    templates_create = V3::Agreement::Templates::Create.new(super_user_session.token, user_email, base_url, type, template_name)
    temp_id = templates_create.id
    resp_code = templates_create.response.code
    expect(resp_code).to eq 200
    test_rail_result(2, "templates_create header: #{templates_create.response.headers}")
    test_rail_result(2, "templates_create body: #{templates_create.response.body}")
    test_rail_result(2, "creating agreement template response code: #{resp_code}", "pass")

    #Step3 The user makes a POST request on {{protocol}}{{url}}/v3/file_uploads
    test_rail_expected_result(3, "User should sSee the created agreement template displayed in the response with an id")
    #POST request on {{protocol}}{{url}}/v3/file_uploads
    file_upload = V3::FileUploads::Post.new(super_user_session.token, user_email, base_url, temp_id, type)
    resp_code = file_upload.response.code
    test_rail_result(3, "file_upload header: #{file_upload.response.headers}")
    test_rail_result(3, "file_upload body: #{file_upload.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(3, "file upload response code: #{resp_code}", "pass")

    #Step4 The user makes a Get request on {{protocol}}{{url}}/v3/agreement/templates/:id
    test_rail_expected_result(4, "User should see uploaded file url in the response and should see the associated id")
    #POST request on {{protocol}}{{url}}/v3/agreement/templates
    templates_show = V3::Agreement::Templates::Show.new(super_user_session.token, user_email, base_url, temp_id)
    resp_code = templates_show.response.code
    resp_json = JSON.parse(templates_show.response.body)
    expect(resp_code).to eq 200
    test_rail_result(4, "templates_show header: #{templates_show.response.headers}")
    test_rail_result(4, "templates_show body: #{templates_show.response.body}")
    test_rail_result(4, "getting agreement template response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'document_url')).not_to eq nil
    test_rail_result(4, "uplodaed file url in response: #{resp_json.dig('data', 'attributes', 'document_url')}", "pass")
  end

end

