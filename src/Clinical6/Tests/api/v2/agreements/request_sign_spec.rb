require_relative '../../../../../../src/spec_helper'

describe 'Post V2/agreements/request_sign' do #, type: :feature, js: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "request_sign" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:screenshot_path) { test_data["screenshot_path"] }
  let(:template_id) { test_data["template_id"] }
  let(:recepient_email) { test_data["recepient_email"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, url).token }
  let(:request_sign) { V2::Agreements::RequestSign.new(token, user_email, url, recepient_email, template_id) }

  context 'with valid data' do
    it 'responds with 200 status code' do
      expect(request_sign.response.code).to eq 200
    end

    it 'has a sign_url document' do
      expect(request_sign.sign_url.length).to be > 1
      #todo: verify url is a uri
      #todo: verify url returns 200
=begin
      puts ""
      puts request_sign.response
      puts 'sign_url: ' + JSON.parse(request_sign.response).dig('signatures', 0, 'sign_url')
      puts 'mobile_user_id: ' + JSON.parse(request_sign.response).dig('signatures', 0, 'mobile_user_id').to_s
      document_url = JSON.parse(request_sign.response).dig('document_url')
      puts 'document url: ' + document_url
      visit document_url
      page.has_selector?(:css, 'pdf_loaded', wait: 2)
      page.save_screenshot(screenshot_path + 'sign_PDF.png')
=end

    end

  end
end



