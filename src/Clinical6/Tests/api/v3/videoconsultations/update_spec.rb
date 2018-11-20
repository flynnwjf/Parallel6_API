require_relative '../../../../../../src/spec_helper'

describe 'Patch V3/video_consultations/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "video_consultations_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:update_name) { "Update Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::VideoConsultations::Create.new(token, user_email, base_url, name).id }
  let(:video_consultations_update) { V3::VideoConsultations::Update.new(token, user_email, base_url, id, update_name) }
  let(:video_consultations_delete) { V3::VideoConsultations::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 code and update video consultation' do
      expect(video_consultations_update.response.code).to eq 200
      expect(JSON.parse(video_consultations_update.response.body).dig("data", "id")).to eq id
      expect(JSON.parse(video_consultations_update.response.body).dig("data", "attributes", "name")).to eq update_name
      #Clean Up
      expect(video_consultations_delete.response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:update_name) {test_data["invalid_name"]}
    it 'returns 422 error & cannot be blank message in body' do
      expect(video_consultations_update.response.code).to eq 422
      expect(video_consultations_update.response.body).to match /can't be blank/
    end
  end

end

