require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/discuss/threads' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "threads_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:flow_process_id) { V3::DataCollection::FlowProcesses::Index.new(token, user_email, base_url).id }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:threads_create) { V3::Discuss::Threads::Create.new(token, user_email, base_url, flow_process_id) }

  context 'with valid user' do
    it 'returns 201 status and creates thread' do
      expect(threads_create.response.code).to eq 201
      expect(JSON.parse(threads_create.response.body).dig("data", "id")).not_to eq nil
      expect(JSON.parse(threads_create.response.body).dig("data", "type")).to eq "commentable__threads"
      #Clean Up
      expect(V3::Discuss::Threads::Update.new(token, user_email, base_url, threads_create.id, "resolved").response.code).to eq 200
    end
  end

  context 'with invalid user' do
    let(:flow_process_id) { test_data["id"] }
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(threads_create.response.code).to eql 401
      expect(threads_create.response.body).to match /Authentication Failed/
    end
  end

end



