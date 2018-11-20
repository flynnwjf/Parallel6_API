require_relative '../../../../../../src/spec_helper'

describe 'Post V3/video_consultation_join' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "video_consultations_join" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:video_consultation_id) { V3::VideoConsultations::Create.new(token, user_email, base_url, name).id }
  let(:video_consultation_participant_id) { V3::VideoConsultationParticipants::Create.new(token, user_email, base_url, video_consultation_id).participant_id }
  let(:video_consultations_delete) { V3::VideoConsultations::Delete.new(token, user_email, base_url, video_consultation_id) }

  context 'with valid user' do
    let(:video_consultations_join) { V3::VideoConsultations::Join.new(token, user_email, base_url, video_consultation_id, video_consultation_participant_id)  }
    it 'returns 201 code and joins video consultation' do
      expect(video_consultations_join.response.code).to eq 200
      expect(JSON.parse(video_consultations_join.response.body).dig("meta", "join_token")).not_to eq ""
      #Clean Up
      expect(video_consultations_delete.response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:video_consultation_id) { test_data["invalid_video_consultation_id"] }
    let(:video_consultation_participant_id) { test_data["invalid_video_consultation_participant_id"] }
    let(:video_consultations_join) { V3::VideoConsultations::Join.new(token, user_email, base_url, video_consultation_id, video_consultation_participant_id)  }
    it 'returns 422 error & Invalid parameters message in body' do
      expect(video_consultations_join.response.code).to eq 422
      expect(video_consultations_join.response.body).to match /Invalid parameters/
    end
  end

end

