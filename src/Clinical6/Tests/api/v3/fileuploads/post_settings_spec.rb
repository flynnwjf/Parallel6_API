require_relative '../../../../../../src/spec_helper'

describe 'Post V3/file_uploads(postSettings)' do
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
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:file){'new'}

  let(:file_uploads_settings) { V3::FileUploads::PostSettings.new(token, user_email, base_url, id, file,attribute) }

  context 'with valid user' do

    it 'returns 201 code and uploads new logo' do
      expect(file_uploads_settings.response.code).to eq 201
    end
  end

  context 'with invalid attribute' do
    let(:attribute){"bad_attribute"}
    it 'returns 400 error' do
      expect(file_uploads_settings.response.code).to eq 400
      expect(file_uploads_settings.response.body).to match /bad_attribute/
    end
  end

end

