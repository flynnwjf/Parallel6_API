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

  it 'C14249 System should allow a user to upload a file to the system', test_id: 'C14249' do
    test_rail_expected_steps(3)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/agreement/templates
    test_rail_expected_result(1, "The agreement template is created and the user notes the agreement_template_id")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/agreement/templates
    templates_create = V3::Agreement::Templates::Create.new(super_user_session.token, user_email, base_url, type, template_name)
    temp_id = templates_create.id
    resp_code = templates_create.response.code
    expect(resp_code).to eq 200
    test_rail_result(1, "templates_create header: #{templates_create.response.headers}")
    test_rail_result(1, "templates_create body: #{templates_create.response.body}")
    test_rail_result(1, "creating agreement template response code: #{resp_code}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/file_uploads
    test_rail_expected_result(2, "The user receives 201 Created response and a File URL is created")
    #POST request on {{protocol}}{{url}}/v3/file_uploads
    file_upload = V3::FileUploads::Post.new(super_user_session.token, user_email, base_url, temp_id, type)
    resp_code = file_upload.response.code
    test_rail_result(2, "file_upload header: #{file_upload.response.headers}")
    test_rail_result(2, "file_upload body: #{file_upload.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(2, "file upload response code: #{resp_code}", "pass")

    #Step3 The user makes a Get request on {{protocol}}{{url}}/v3/agreement/templates/:id
    test_rail_expected_result(3, "The agreement templates are listed and the File URL under the agreement_template_id from step 1 is the File URL from step 2")
    #POST request on {{protocol}}{{url}}/v3/agreement/templates
    templates_show = V3::Agreement::Templates::Show.new(super_user_session.token, user_email, base_url, temp_id)
    resp_code = templates_show.response.code
    resp_json = JSON.parse(templates_show.response.body)
    expect(resp_code).to eq 200
    test_rail_result(3, "templates_show header: #{templates_show.response.headers}")
    test_rail_result(3, "templates_show body: #{templates_show.response.body}")
    test_rail_result(3, "getting agreement template response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'attributes', 'document_url')).not_to eq nil
    test_rail_result(3, "uplodaed file url in response: #{resp_json.dig('data', 'attributes', 'document_url')}", "pass")
  end

end

