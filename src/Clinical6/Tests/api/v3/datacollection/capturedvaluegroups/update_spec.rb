require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/data_collection/captured_value_groups/:id' do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "datacollection_capturedvaluegroups_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }
#Requests
  let(:request){V3::Users::Session::Create.new(user_email, user_password, base_url)}
  let(:token) { request.token }
  let(:datacollection_capturedvaluegroups_update) { V3::DataCollection::CapturedValueGroups::Update.new(token, user_email, base_url, id, enabled) }

  context 'with valid user' do

    context 'when updating final submission to disabled' do
      let(:enabled) { false }
      it 'returns 200 and final submission to disabled' do
        expect(datacollection_capturedvaluegroups_update.response.code).to eq 200
        expect(JSON.parse(datacollection_capturedvaluegroups_update.response.body).dig('data', 'id')).to eql id
        expect(JSON.parse(datacollection_capturedvaluegroups_update.response.body).dig('data', 'attributes', 'final_submission')).to eql enabled
      end
    end

    context 'when updating final submission to enabled' do
      let(:enabled) { true }
      it 'returns 200 and final submission to enabled' do
        expect(datacollection_capturedvaluegroups_update.response.code).to eq 200
        expect(JSON.parse(datacollection_capturedvaluegroups_update.response.body).dig('data', 'id')).to eql id
        expect(JSON.parse(datacollection_capturedvaluegroups_update.response.body).dig('data', 'attributes', 'final_submission')).to eql enabled
      end
    end

  end

  context 'with invalid user' do
    let(:id) { test_data["invalid_id"] }
    let(:enabled) { true }
    it 'returns 404 error & record not found message' do
      expect(datacollection_capturedvaluegroups_update.response.code).to eq 404
      expect(datacollection_capturedvaluegroups_update.response.body).to match /Record Not Found/
    end
  end

end

