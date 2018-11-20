require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/data_collection/flow_process_values/:id' do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "datacollection_flowprocessvalues_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:datacollection_flowprocessvalues_show) { V3::DataCollection::FlowProcessValues::Show.new(token, user_email, base_url, id) }


  context 'with valid user' do
    it 'returns 200 status code and shows flow process values' do
      expect(datacollection_flowprocessvalues_show.response.code).to eq 200
      expect(JSON.parse(datacollection_flowprocessvalues_show.response.body).dig('data', 'id')).not_to eq nil
      expect(JSON.parse(datacollection_flowprocessvalues_show.response.body).dig('data', 'type')).to eq "data_collection__flow_process_values"
    end
  end

   context 'with invalid group id and mobile user id' do
     let(:id) { test_data["invalid_id"] }
     it 'returns 404 error and Record Not Found error message' do
       expect(datacollection_flowprocessvalues_show.response.code).to eq 404
       expect(datacollection_flowprocessvalues_show.response.body).to match /Record Not Found/
     end
  end

end



