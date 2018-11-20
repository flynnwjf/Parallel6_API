require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/batching/batches' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "batching_batches_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:batching_batches_index) { V3::Batching::Batches::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code & shows batching batches' do
      expect(batching_batches_index.response.code).to eq 200
      if !JSON.parse(batching_batches_index.response).dig('data', 0, 'id').eql? nil
        expect(JSON.parse(batching_batches_index.response).dig('data', 0, 'type')).to eq "batching__batches"
      end
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    it 'returns 403 Forbidden' do
      expect(batching_batches_index.response.code).to eql 403
      expect(batching_batches_index.response.body).to match /Authorization Failure/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(batching_batches_index.response.code).to eql 401
      expect(batching_batches_index.response.body).to match /Authentication Failed/
    end
  end

end



