require_relative '../../../../../../../src/spec_helper'

describe 'Delete V3/cohort_assignments/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "cohort_assignment_del" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:cohort_type){"static"}
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }

  context 'with valid user' do

    let(:cohort_id) { V3::Cohort::Create.new(token, user_email, base_url, name, cohort_type).cohort_id }
    let(:cohort_assignment_id) { V3::Cohort::CohortAssignment::Create.new(token, user_email, base_url, cohort_id, type).cohort_assignment_id }
    let(:cohort_assignment_del) { V3::Cohort::CohortAssignment::Delete.new(token, user_email, base_url, cohort_assignment_id) }

    xit 'returns 204 code and deletes cohort assignment' do
      expect(cohort_assignment_del.response.code).to eq 204
    end

  end


  context 'with invalid id' do

    let(:cohort_assignment_id) { test_data["invalid_id"] }
    let(:cohort_assignment_del) { V3::Cohort::CohortAssignment::Delete.new(token, user_email, base_url, cohort_assignment_id) }

    it 'returns 404 error & Record Not Found message in body' do
      expect(cohort_assignment_del.response.code).to eq 404
      expect(cohort_assignment_del.response.body).to match /Record Not Found/
    end

  end

end

