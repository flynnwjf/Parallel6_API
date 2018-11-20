require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/mobile_users/:id/data_collection/captured_value_groups/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "datacollection_capturedvaluegroups_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:datacollection_capturedvaluegroups_index) { V3::DataCollection::CapturedValueGroups::Index.new(token, user_email, base_url) }
  let(:group_id) { datacollection_capturedvaluegroups_index.id[:group] }
  let(:mobile_user_id) { datacollection_capturedvaluegroups_index.id[:mobile_user] }
  let(:datacollection_capturedvaluegroups_show) { V3::DataCollection::CapturedValueGroups::Show.new(token, user_email, base_url, mobile_user_id, group_id) }


  context 'with valid user' do
    it 'returns 200 status code and shows captured value groups' do
      expect(datacollection_capturedvaluegroups_show.response.code).to eq 200
      expect(JSON.parse(datacollection_capturedvaluegroups_show.response.body).dig('data', 'id')).to eq group_id
      expect(JSON.parse(datacollection_capturedvaluegroups_show.response.body).dig('data', 'type')).to eq "data_collection__captured_value_groups"
    end
  end

   context 'with invalid group id and mobile user id' do
     let(:group_id) { test_data["invalid_group_id"] }
     let(:mobile_user_id) { test_data["invalid_mobile_user_id"] }
    it 'returns 404 error' do
      expect(datacollection_capturedvaluegroups_show.response.code).to eq 404
      expect(datacollection_capturedvaluegroups_show.response.body).to match /Record Not Found/
    end
  end

end



