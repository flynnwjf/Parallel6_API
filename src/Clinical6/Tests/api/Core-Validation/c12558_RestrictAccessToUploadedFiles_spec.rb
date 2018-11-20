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
  let(:testname) { 'file_uploads' }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:test_steps) { 3 }

  it 'C12558 System should restrict the access to files uploaded by other users.', test_id: 'C12558' do
    test_rail_expected_steps(test_steps)
    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/agreement/templates
    step = 1
    test_rail_expected_result(step, "It returns 201 and new agreement template is created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(step, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(step, "Super User session body: #{super_user_session.response.body}")

    #POST request on {{protocol}}{{url}}/v3/agreement/templates
    id = 2
    type = 'agreement__templates'
    test_rail_expected_result(step, "It returns 201 and S3 URL for .PDF")
    file_upload = V3::FileUploads::Post.new(super_user_session.token, user_email, base_url, id, type)
    test_rail_result(step, "agreement_template header: #{file_upload.response.headers}")
    test_rail_result(step, "agreement_template body: #{file_upload.response.body}")

    expect(file_upload.body.response.code).to eq 201
    expect(file_upload.body.url).not_to eq nil
    test_rail_result(step, "Valid file upload returns status code: #{file_upload.body.response.code}", "pass")


  end

end

