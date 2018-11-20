require_relative '../../../../../../src/spec_helper'

describe 'Post V3/cohorts' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "cohort_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:cohort_type){"static"}
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:cohort_create) { V3::Cohort::Create.new(token, user_email, base_url, name,cohort_type) }

  context 'with valid user' do
    it 'returns 201 code and create cohort' do
      expect(cohort_create.response.code).to eq 201
      expect(JSON.parse(cohort_create.response.body).dig("data", "attributes", "name")).to eq name
      expect(JSON.parse(cohort_create.response.body).dig("data", "type")).to eq "cohorts"
    end
  end

  context 'with invalid parameter' do
    let(:name) { test_data["invalid_name"] }
    it 'returns 422 error & cannot be blank message in body' do
      expect(cohort_create.response.code).to eq 422
      expect(cohort_create.response.body).to match /can't be blank/
    end
  end

end

