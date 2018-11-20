require_relative '../../../../../../src/spec_helper'

describe 'Post V3/video_consultation_participants' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "video_consultation_participant_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:video_consultation_participant_create) { V3::VideoConsultationParticipants::Create.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:id) {test_data["id"]}
    it 'returns 201 code and create video consultation participant' do
      expect(video_consultation_participant_create.response.code).to eq 201
      expect(JSON.parse(video_consultation_participant_create.response.body).dig("data", "type")).to eq "video_consultation_participants"
    end
  end

  context 'with invalid parameter' do
    let(:id) {test_data["invalid_id"]}
    it 'returns 422 error & Invalid parameter message in body' do
      expect(video_consultation_participant_create.response.code).to eq 422
      expect(video_consultation_participant_create.response.body).to match /Invalid parameter/
    end
  end

end

