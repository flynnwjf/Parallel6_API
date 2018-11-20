require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/data_collection/flow_processes' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "datacollection_flowprocesses_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test Flow " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:link) { "test_flow_" + Time.new.strftime("%Y-%m-%d-%H-%M-%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:datacollection_flowprocesses_create) { V3::DataCollection::FlowProcesses::Create.new(token, user_email, base_url, name, link) }

  context 'with valid user' do
    it 'returns 201 status code & create a flow process' do
      expect(datacollection_flowprocesses_create.response.code).to eq 201
      expect(JSON.parse(datacollection_flowprocesses_create.response).dig('data', 'id')).not_to eq ""
      expect(JSON.parse(datacollection_flowprocesses_create.response).dig('data', 'type')).to eq "data_collection__flow_processes"
      expect(JSON.parse(datacollection_flowprocesses_create.response).dig('data', 'attributes', 'name')).to eq name
      expect(JSON.parse(datacollection_flowprocesses_create.response).dig('data', 'attributes', 'permanent_link')).to eq (link + "_published")
    end
  end

  context 'with invalid parameters' do
    let(:name) { test_data["invalid_name"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(datacollection_flowprocesses_create.response.code).to eq 422
      expect(datacollection_flowprocesses_create.response.body).to match /can\'t be blank/
    end
  end

end



