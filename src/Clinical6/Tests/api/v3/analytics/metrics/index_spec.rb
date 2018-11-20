require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/analytics/metrics' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "analytics_metrics_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:analytics_metrics_index) { V3::Analytics::Metrics::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code & shows analytics metrics' do
      expect(analytics_metrics_index.response.code).to eq 200
      #Currently there is no data in response
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    it 'returns 403 Forbidden' do
      expect(analytics_metrics_index.response.code).to eql 403
      expect(analytics_metrics_index.response.body).to match /Authorization Failure/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(analytics_metrics_index.response.code).to eql 401
      expect(analytics_metrics_index.response.body).to match /Authentication Failed/
    end
  end

end



