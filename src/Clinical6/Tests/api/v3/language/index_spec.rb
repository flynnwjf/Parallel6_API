require_relative '../../../../../../src/spec_helper'

describe 'Get V3/languages' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "language_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:language_index) { V3::Languages::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code & shows the languages' do
      expect(language_index.response.code).to eq 200
      expect(JSON.parse(language_index.response.body).dig("data", 0,"id")).not_to eq nil
      expect(JSON.parse(language_index.response.body).dig("data", 0,"type")).to eq "languages"
    end
  end

end



