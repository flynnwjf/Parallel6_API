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
  let(:testname) { "agreement_templatesfields_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:test_steps) { 2 }

  it 'C12041 - System should scan uploaded files for viruses.', test_id: 'C12041' do
    test_rail_expected_steps(test_steps)
    step = 1
    test_rail_expected_result(step, "POST agreement template to /v3/agreement/templates")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(step, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(step, "Super User session body: #{super_user_session.response.body}")
    
    step = 1
    test_rail_expected_result(step, "POST agreement template (with virus) to /v3/agreement/templates")
    id = 1
    type = "agreement__templates"
    
    eicar = V3::FileUploads::Post.new(super_user_session.token, user_email, base_url, id, type, File.new(File.dirname(__FILE__) + '/eicar/eicar.pdf'))
    test_rail_result(step, "Post eicar virus pdf header: #{eicar.response.headers}")
    test_rail_result(step, "Post eicar virus pdf body: #{eicar.response.body}")
    expect(eicar.response.code == 201).to be false
    test_rail_result(step, "response response code: #{eicar.response.code}", "pass")

    eicar_com = V3::FileUploads::Post.new(super_user_session.token, user_email, base_url, id, type, File.new(File.dirname(__FILE__) + '/eicar/eicar_com.pdf'))
    test_rail_result(step, "Post eicar_com virus pdf header: #{eicar_com.response.headers}")
    test_rail_result(step, "Post eicar_com virus pdf body: #{eicar_com.response.body}")
    expect(eicar_com.response.code == 201).to be false
    test_rail_result(step, "response response code: #{eicar_com.response.code}", "pass")

    eicarcom2 = V3::FileUploads::Post.new(super_user_session.token, user_email, base_url, id, type, File.new(File.dirname(__FILE__) + '/eicar/eicarcom2.pdf'))
    test_rail_result(step, "Post eicarcom2 virus pdf header: #{eicarcom2.response.headers}")
    test_rail_result(step, "Post eicarcom2 virus pdf body: #{eicarcom2.response.body}")
    expect(eicarcom2.response.code == 201).to be false
    test_rail_result(step, "response response code: #{eicarcom2.response.code}", "pass")
    
    #Step2 POST {{protocol}}{{url}}/v3/file_uploads.
    # id=1, type=agreement_templates, file=pdf, attribute=document
    # Upload a file that has no virus
    # Expected: Success alert message is displayed
    step = 2
    test_rail_expected_result(step, "POST agreement template (no virus) to /v3/agreement/templates")
    pdf_post_resp = V3::FileUploads::Post.new(super_user_session.token, user_email, base_url, id, type)
    test_rail_result(step, "Post valid pdf header: #{pdf_post_resp.response.headers}")
    test_rail_result(step, "Post valid pdf body: #{pdf_post_resp.response.body}")
    expect(pdf_post_resp.response.code == 201).to be true
    test_rail_result(step, "response response code: #{pdf_post_resp.response.code}", "pass")
  end

end

