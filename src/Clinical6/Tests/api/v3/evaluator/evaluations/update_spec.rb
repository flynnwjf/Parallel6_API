require_relative '../../../../../../../src/spec_helper'

describe 'Patch V3/evaluator/evaluations/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "evaluator_evaluations_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "UpdateQualification" + Time.new.strftime("%Y%m%d%H%M%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::Evaluator::Evaluations::Index.new(token, user_email, base_url).id }
  let(:evaluator_evaluations_update) { V3::Evaluator::Evaluations::Update.new(token, user_email, base_url, id, name) }

  context 'with valid user' do
    it 'returns 200 status code & create an evaluation' do
      DataHandler.change_test_data_value(testname, "id", id)
      expect(evaluator_evaluations_update.response.code).to eq 200
      expect(JSON.parse(evaluator_evaluations_update.response).dig('data','id')).to eq id
      expect(JSON.parse(evaluator_evaluations_update.response).dig('data','type')).to eq "evaluator__evaluations"
      expect(JSON.parse(evaluator_evaluations_update.response).dig('data','attributes','name')).to eq name
    end
  end

  context 'with invalid parameters' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(evaluator_evaluations_update.response.code).to eq 404
      expect(evaluator_evaluations_update.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:id) { test_data["id"] }
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(evaluator_evaluations_update.response.code).to eql 401
      expect(evaluator_evaluations_update.response.body).to match /Authentication Failed/
    end
  end

end



