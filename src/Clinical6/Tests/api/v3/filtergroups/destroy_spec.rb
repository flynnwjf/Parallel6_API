require_relative '../../../../../../src/spec_helper'

describe 'Delete V3/filter_groups/:id/destroy' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Unauthorized User
  let(:env_unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_email) { env_unauthorized_user["email"] }
  let(:unauthorized_password) { env_unauthorized_user["password"] }
#Preconditions
  let(:pre_testname) { "filter_groups_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
 #Test Info
  let(:testname) { "filter_groups_destroy" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:cohort_type) {"dynamic"}
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:filter_groups_destroy) { V3::FilterGroups::Destroy.new(token, user_email, base_url, id) }

  context 'with valid user' do
    let(:cohort_id) { V3::Cohort::Create.new(token, user_email, base_url, "dynamic_cohort" + DateTime.now.strftime('+%Q'), cohort_type).cohort_id}

    let(:id) { V3::FilterGroups::Create.new(token, user_email, base_url, type, cohort_id).id }
    it 'returns 204 status code' do
      expect(filter_groups_destroy.response.code).to eq 204
      #cleanup
      #Pendng cohort delete implementation
      #expect(V3::Cohort::Delete.new(token, user_email, base_url, cohort_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(filter_groups_destroy.response.code).to eq 404
      expect(filter_groups_destroy.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:unauthorized_user_token) { V3::Users::Session::Create.new(unauthorized_email, unauthorized_password, base_url).token }
    let(:cohort_id) { V3::Cohort::Create.new(token, user_email, base_url, "dynamic_cohort" + DateTime.now.strftime('+%Q'), cohort_type).cohort_id}
    let(:id) { V3::FilterGroups::Create.new(token, user_email, base_url, type, cohort_id).id }
    let(:filter_groups_destroy) { V3::FilterGroups::Destroy.new(unauthorized_user_token, unauthorized_email, base_url, id) }
    it 'returns 403 error' do
      expect(filter_groups_destroy.response.code).to eq 403
      #cleanup
      #expect(V3::Cohort::Delete.new(token, user_email, base_url, cohort_id).response.code).to eq 204
      expect(V3::FilterGroups::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:filter_groups_destroy) { V3::FilterGroups::Destroy.new(token, invalid_user, base_url, id) }
    let(:id) { "1" }
    it 'returns 401 error' do
      expect(filter_groups_destroy.response.code).to eq 401
      expect(filter_groups_destroy.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



