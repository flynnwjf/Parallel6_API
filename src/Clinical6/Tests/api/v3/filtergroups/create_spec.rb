require_relative '../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/filter_groups/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "filter_groups_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:cohort_type){"dynamic"}
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:filter_groups_create) { V3::FilterGroups::Create.new(token, user_email, base_url, type, cohort_id) }
  let(:created_id) { filter_groups_create.id}

  context 'with valid user' do
    let(:cohort_create) { V3::Cohort::Create.new(token, user_email, base_url, "dynamic_cohort" + DateTime.now.strftime('+%Q'),cohort_type)}
    let(:cohort_id) { cohort_create.cohort_id }
    it 'returns 201 status code ' do
      expect(cohort_create.response.code).to eq 201
      expect(filter_groups_create.response.code).to eq 201
      expect(JSON.parse(filter_groups_create.response).dig('data','type')).to eq type
      expect(JSON.parse(filter_groups_create.response).dig('data', 'relationships','cohort', 'data', 'id')).to eq cohort_id
      #cleanup
      #Pendng cohort delete implementation
      #expect(V3::Cohort::Delete.new(token, user_email, base_url, cohort_id).response.code).to eq 204
      expect(V3::FilterGroups::Destroy.new(token, user_email, base_url, created_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:cohort_id) { test_data["invalid_parameter"] }
    it 'returns 422 error' do
      expect(filter_groups_create.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:cohort_id) { "1" }
    it 'returns 403 error' do
      expect(filter_groups_create.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:filter_groups_create) { V3::FilterGroups::Create.new(token, invalid_user, base_url, type, "1") }
    it 'returns 401 error' do
      expect(filter_groups_create.response.code).to eq 401
      expect(filter_groups_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



