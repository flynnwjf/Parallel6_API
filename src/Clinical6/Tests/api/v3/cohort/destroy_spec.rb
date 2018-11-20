require_relative '../../../../../../src/spec_helper'

describe 'Delete V3/cohorts/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "cohort_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:cohort_type){"static"}
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:cohort_create_id) { V3::Cohort::Create.new(token, user_email, base_url, name, cohort_type).cohort_id }
  let(:cohort_delete) { V3::Cohort::Delete.new(token, user_email, base_url, cohort_create_id) }

  context 'with valid user' do
    #Pendng cohort delete implementation
    xit 'returns 201 code and deletes cohort' do
      expect(cohort_delete.response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:cohort_create_id) { test_data["invalid_name"] }
    #Pendng cohort delete implementation
    xit 'returns 422 error & cannot be blank message in body' do
      expect(cohort_delete.response.code).to eq 422
      expect(cohort_delete.response.body).to match /can't be blank/
    end
  end

end

