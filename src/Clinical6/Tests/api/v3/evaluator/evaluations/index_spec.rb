require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/evaluator/evaluations' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "evaluator_evaluations_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:evaluator_evaluations_index) { V3::Evaluator::Evaluations::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code & show evaluations' do
      expect(evaluator_evaluations_index.response.code).to eq 200
      expect(JSON.parse(evaluator_evaluations_index.response).dig('data',0,'id')).not_to eq nil
      expect(JSON.parse(evaluator_evaluations_index.response).dig('data',0,'type')).to eq "evaluator__evaluations"
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(evaluator_evaluations_index.response.code).to eql 401
      expect(evaluator_evaluations_index.response.body).to match /Authentication Failed/
    end
  end

end



