require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/data_collection/flow_processes' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "datacollection_flowprocesses_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:datacollection_flowprocesses_index) { V3::DataCollection::FlowProcesses::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code and shows flow processes' do
      expect(datacollection_flowprocesses_index.response.code).to eq 200
      expect(JSON.parse(datacollection_flowprocesses_index.response.body).dig('data', 0, 'id')).not_to eq ""
      expect(JSON.parse(datacollection_flowprocesses_index.response.body).dig('data', 0, 'type')).to eq "data_collection__flow_processes"
    end
  end

   context 'with invalid user' do
    let(:user_email) { test_data["invalid_name"] }
    it 'returns 401 error' do
      expect(datacollection_flowprocesses_index.response.code).to eq 401
      expect(datacollection_flowprocesses_index.response.body).to match /Authentication Failed/
    end
  end

end



