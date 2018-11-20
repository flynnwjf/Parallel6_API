require_relative '../../../../../../src/spec_helper'

describe 'Post V3/file_uploads post_spec' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "file_uploads" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type){"agreement__templates"}
  let(:file){'new'}
  let(:id) {test_data["id"]}

#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:file_uploads) { V3::FileUploads::Post.new(token, user_email, base_url, id, type, file) }

  context 'with valid user' do
    #Todo: investigate why pdfs are not allowed
    xit 'returns 201 code and uploads file' do
      expect(file_uploads.response.code).to eq 201
      expect(JSON.parse(file_uploads.response.body).dig("file_url")).not_to eq ""
    end
  end

  context 'with invalid id' do
    let(:id) {test_data["invalid_id"]}
    xit 'returns 404 error & Record Not Found message in body' do
      expect(file_uploads.response.code).to eq 404
      expect(file_uploads.response.body).to match /Record Not Found/
    end
  end

end

