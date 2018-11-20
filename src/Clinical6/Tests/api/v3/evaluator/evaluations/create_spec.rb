require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/evaluator/evaluations' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "evaluator_evaluations_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Qualification" + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:link) { "qualification_" + Time.new.strftime("%Y%m%d_%H%M%S") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:evaluator_evaluations_create) { V3::Evaluator::Evaluations::Create.new(token, user_email, base_url, name, link) }

  context 'with valid user' do
    it 'returns 201 status code & create an evaluation' do
      expect(evaluator_evaluations_create.response.code).to eq 201
      expect(JSON.parse(evaluator_evaluations_create.response).dig('data','id')).not_to eq nil
      expect(JSON.parse(evaluator_evaluations_create.response).dig('data','type')).to eq "evaluator__evaluations"
      expect(JSON.parse(evaluator_evaluations_create.response).dig('data','attributes','name')).to eq name
    end
  end

  context 'with invalid parameters' do
    let(:name) { test_data["invalid_name"] }
    let(:link) { test_data["invalid_link"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(evaluator_evaluations_create.response.code).to eq 422
      expect(evaluator_evaluations_create.response.body).to match /can\'t be blank/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(evaluator_evaluations_create.response.code).to eql 401
      expect(evaluator_evaluations_create.response.body).to match /Authentication Failed/
    end
  end

end



