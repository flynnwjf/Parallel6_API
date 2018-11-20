require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/cohort_assignments' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "cohort_assignment_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:cohort_type){ test_data["cohort_type"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }

  context 'with valid user' do

    let(:cohort_id) { V3::Cohort::Create.new(token, user_email, base_url, name, cohort_type).cohort_id }
    let(:cohort_assignment_create) { V3::Cohort::CohortAssignment::Create.new(token, user_email, base_url, cohort_id, type) }
    let(:cohort_assignment_id) { cohort_assignment_create.cohort_assignment_id }

    it 'returns 201 code and create cohort assignment' do
      expect(cohort_assignment_create.response.code).to eq 201
      expect(JSON.parse(cohort_assignment_create.response.body).dig("data", "type")).to eq "cohort_assignments"

      #todo: add cleanup once delete cohort assignment endpoint is done
      #cohort_assignment_cleanup = V3::Cohort::CohortAssignment::Delete.new(token, user_email, base_url, cohort_assignment_id)
      #expect(cohort_assignment_cleanup.response.code).to eq 204

      #There is no Cohort::Delete API in http://clinical6-docs.s3-website-us-east-1.amazonaws.com/apidoc.html
      #I get 404 error when I try to request Del /v3/cohorts/:id
    end

  end


  context 'with invalid parameter' do

    let(:cohort_id) { test_data["invalid_id"] }
    let(:cohort_assignment_create) { V3::Cohort::CohortAssignment::Create.new(token, user_email, base_url, cohort_id, type) }

    it 'returns 422 error & Invalid parameters message in body' do
      expect(cohort_assignment_create.response.code).to eq 422
      expect(cohort_assignment_create.response.body).to match /Invalid parameters/
    end

  end

end

