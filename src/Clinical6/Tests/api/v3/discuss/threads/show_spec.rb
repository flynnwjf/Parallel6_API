require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/discuss/threads/show' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "threads_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:thread_id) { test_data["thread_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:threads_show) { V3::Discuss::Threads::Show.new(token, user_email, base_url, thread_id) }

  context 'with valid user' do
    it 'returns 200 status code id to match' do
      expect(threads_show.response.code).to eq 200
      expect(JSON.parse(threads_show.response.body).dig("data", "type")).to eq "commentable__threads"
      expect(JSON.parse(threads_show.response.body).dig("data", "id")).to eq thread_id

    end
  end

  context 'with invalid data' do
    let(:thread_id) { "-1" }
    it 'returns 404 error' do
      expect(threads_show.response.code).to eq 404
      expect(threads_show.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:user_email) { "-1" }
    it 'returns 401 error' do
      expect(threads_show.response.code).to eq 401
      expect(threads_show.response.body).to match /Authentication Failed/
    end
  end

end



