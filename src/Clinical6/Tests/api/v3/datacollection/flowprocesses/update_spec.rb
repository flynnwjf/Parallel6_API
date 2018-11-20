require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/data_collection/flow_processes/:id' do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "datacollection_flowprocesses_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }
  let(:name) { test_data["name"] }
  let(:link) { "test_flow_" + Time.new.strftime("%Y-%m-%d-%H-%M-%S") }
  let(:description) { "test description " + Time.new.strftime("%Y-%m-%d-%H-%M-%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:datacollection_flowprocesses_update) { V3::DataCollection::FlowProcesses::Update.new(token, user_email, base_url, id, link, description, name) }

  context 'with valid user' do
     it 'returns 200 status code & update a flow process' do
      expect(datacollection_flowprocesses_update.response.code).to eq 200
      expect(JSON.parse(datacollection_flowprocesses_update.response).dig('data', 'id')).to eq id
      expect(JSON.parse(datacollection_flowprocesses_update.response).dig('data', 'type')).to eq "data_collection__flow_processes"
      expect(JSON.parse(datacollection_flowprocesses_update.response).dig('data', 'attributes', 'description')).to eq description
      expect(JSON.parse(datacollection_flowprocesses_update.response).dig('data', 'attributes', 'permanent_link')).not_to eq link
    end
  end

  context 'with invalid parameters' do
    let(:name) { test_data["invalid_name"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(datacollection_flowprocesses_update.response.code).to eq 422
      expect(datacollection_flowprocesses_update.response.body).to match /can\'t be blank/
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(datacollection_flowprocesses_update.response.code).to eq 404
      expect(datacollection_flowprocesses_update.response.body).to match /Record Not Found/
    end
  end

end



