require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/analytics/metrics/AverageTimeToGiveConsentInSeconds/index' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "analytics_metrics_averagetime_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:analytics_metrics_averagetime_index) { V3::Analytics::Metrics::AverageTime::Index.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code' do
      expect(analytics_metrics_averagetime_index.response.code).to eq 200
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    it 'returns 403 error' do
      expect(analytics_metrics_averagetime_index.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:analytics_metrics_averagetime_index) { V3::Analytics::Metrics::AverageTime::Index.new(token, invalid_user, base_url) }
    it 'returns 401 error' do
      expect(analytics_metrics_averagetime_index.response.code).to eq 401
      expect(analytics_metrics_averagetime_index.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



