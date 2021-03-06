require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/genisis/study_sites/index' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "genisis_studysites_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:genisis_studysites_index) { V3::Genisis::StudySites::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code' do
      expect(genisis_studysites_index.response.code).to eq 200
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  #TODO: Understand how to test unauthorized for genesis
  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    xit 'returns 403 error' do
      expect(genisis_studysites_index.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:genisis_studysites_index) { V3::Genisis::StudySites::Index.new(token, invalid_user, base_url) }
    it 'returns 401 error' do
      expect(genisis_studysites_index.response.code).to eq 401
      expect(genisis_studysites_index.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



