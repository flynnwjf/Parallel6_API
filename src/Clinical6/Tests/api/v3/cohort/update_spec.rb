require_relative '../../../../../../src/spec_helper'

describe 'Patch V3/cohorts/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "cohort_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:create_name) { "Update Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:update_name) { "Update Test " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:cohort_type){ test_data["cohort_type"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }


  context 'with valid user' do
    let(:cohort_create_id) { V3::Cohort::Create.new(token, user_email, base_url, create_name, cohort_type).cohort_id }
    let(:cohort_update) { V3::Cohort::Update.new(token, user_email, base_url, cohort_create_id, update_name) }

    it 'returns 200 code and updates cohorts' do

      expect(cohort_update.response.code).to eq 200
      expect(JSON.parse(cohort_update.response.body).dig("data", "type")).to eq "cohorts"
      expect(JSON.parse(cohort_update.response.body).dig("data", "attributes", "name")).to eq update_name

      #cleanup
      cohort_delete = V3::Cohort::Delete.new(token, user_email, base_url, cohort_create_id)
    end

  end

  context 'with invalid id' do
    let(:id) {test_data["invalid_id"]}
    let(:cohort_update) { V3::Cohort::Update.new(token, user_email, base_url, id, update_name) }
    it 'returns 404 error & Record Not Found message in body' do
      expect(cohort_update.response.code).to eq 404
      expect(cohort_update.response.body).to match /Record Not Found/
    end
  end

end

