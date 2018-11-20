require_relative '../../../../../../src/spec_helper'

describe 'Delete V3/video_consultations/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "video_consultations_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::VideoConsultations::Create.new(token, user_email, base_url, name).id }
  let(:video_consultations_delete) { V3::VideoConsultations::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 204 code and delete video consultation' do
      expect(video_consultations_delete.response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:id) {test_data["invalid_id"]}
    it 'returns 404 error & Record Not Found message in body' do
      expect(video_consultations_delete.response.code).to eq 404
      expect(video_consultations_delete.response.body).to match /Record Not Found/
    end
  end

end

