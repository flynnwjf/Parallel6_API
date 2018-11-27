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
  let(:testname) { "file_uploads_settings" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) {test_data["id"]}
  let(:attribute){"custom_logo"}


  it 'C13015 Admin user should be able to upload the custom_logo', test_id: 'C13015' do
    test_rail_expected_steps(2)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/file_uploads
    test_rail_expected_result(1, "201 Created response is returned, and the file object is created and attached to the Setting.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/file_uploads
    file = 'new'
    file_uploads_settings = V3::FileUploads::PostSettings.new(super_user_session.token, user_email, base_url, id, file, attribute)
    resp_code = file_uploads_settings.response.code
    test_rail_result(1, "file_uploads_settings header: #{file_uploads_settings.response.headers}")
    test_rail_result(1, "file_uploads_settings body: #{file_uploads_settings.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "file_uploads_settings response code: #{resp_code}", "pass")
    file_url = file_uploads_settings.url
    test_rail_result(1, "uploaded file in response: #{file_url}", "pass")

    #Step2 The user makes a POST request on {{protocol}}{{url}}/v3/file_uploads
    test_rail_expected_result(2, "Error response is returned")
    #POST request on {{protocol}}{{url}}/v3/file_uploads
    file = 'large'
    file_uploads_settings = V3::FileUploads::PostSettings.new(super_user_session.token, user_email, base_url, id, file, attribute)
    resp_code = file_uploads_settings.response.code
    test_rail_result(2, "file_uploads_settings header: #{file_uploads_settings.response.headers}")
    test_rail_result(2, "file_uploads_settings body: #{file_uploads_settings.response.body}")
    expect([502, 504, 400].include? resp_code).to be true
    test_rail_result(2, "file_uploads_settings response code: #{resp_code}", "pass")
  end

end

