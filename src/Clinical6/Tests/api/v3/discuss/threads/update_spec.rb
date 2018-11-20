require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/discuss/update' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "threads_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:thread_id) { test_data["thread_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:threads_show_status) { V3::Discuss::Threads::Show.new(token, user_email, base_url, thread_id).status }


  context 'with valid user' do
    it 'returns 200 status and status is updated' do

      case threads_show_status
      when "open"
        threads_update = V3::Discuss::Threads::Update.new(token, user_email, base_url, thread_id, "resolved")
        expect(threads_update.response.code).to eq 200
        expect(V3::Discuss::Threads::Show.new(token, user_email, base_url, thread_id).status ).to match("resolved")
      else
        threads_update = V3::Discuss::Threads::Update.new(token, user_email, base_url, thread_id, "open")
        expect(threads_update.response.code).to eq 200
        expect(V3::Discuss::Threads::Show.new(token, user_email, base_url, thread_id).status ).to match("open")
      end

    end
  end

  context 'with invalid data' do
    let(:threads_update){ V3::Discuss::Threads::Update.new(token, user_email, base_url, thread_id, "open")}
    let(:thread_id) { "-1" }
    it 'returns 404 error' do
      expect(threads_update.response.code).to eq 404
      expect(threads_update.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:user_email) { "-1" }
    let(:threads_update){ V3::Discuss::Threads::Update.new(token, user_email, base_url, thread_id, "open")}

    it 'returns 401 error' do
      expect(threads_update.response.code).to eq 401
      expect(threads_update.response.body).to match /Authentication Failed/
    end
  end

end



