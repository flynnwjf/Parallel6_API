require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/cohorts/:id/cohort_assignments' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "cohort_cohortassignment_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }

  let(:cohort_cohortassignment_index) { V3::Cohort::CohortAssignment::Index.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:id) { test_data["id"] }
    it 'returns 200 code and shows cohort assignment' do
      expect(cohort_cohortassignment_index.response.code).to eq 200
      #expect(JSON.parse(cohort_cohortassignment_index.response.body).dig("data", 0, "type")).to eq "cohort_assignments"
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(cohort_cohortassignment_index.response.code).to eq 404
      expect(cohort_cohortassignment_index.response.body).to match /Record Not Found/
    end
  end

end

