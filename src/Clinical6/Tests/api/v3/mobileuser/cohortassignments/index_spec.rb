require_relative '../../../../../../../src/spec_helper'

describe 'GET V3/mobile_users/:id/cohort_assignments/index' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "mobileuser_cohortassignments_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobileuser_cohortassignments_index) { V3::MobileUser::CohortAssignments::Index.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 status code' do
      expect(mobileuser_cohortassignments_index.response.code).to eq 200
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(mobileuser_cohortassignments_index.response.code).to eq 404
      expect(mobileuser_cohortassignments_index.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 403 error' do
      expect(mobileuser_cohortassignments_index.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 401 error' do
      expect(mobileuser_cohortassignments_index.response.code).to eq 401
      expect(mobileuser_cohortassignments_index.response.body).to match /Authentication Failed/
    end
  end

end



