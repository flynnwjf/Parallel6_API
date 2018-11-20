require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/analytics/metrics/:(id,name)' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "analytics_metrics_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { test_data["name"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:analytics_metrics_show) { V3::Analytics::Metrics::Show.new(token, user_email, base_url, name) }

  context 'with valid user' do
    it 'returns 200 status code & shows analytics metrics with the supplied name' do
      expect(analytics_metrics_show.response.code).to eq 200
      expect(JSON.parse(analytics_metrics_show.response).dig('data', 'id')).not_to eq nil
      expect(JSON.parse(analytics_metrics_show.response).dig('data', 'type')).to eq "analytics__metrics__kpi_values"
      expect(JSON.parse(analytics_metrics_show.response).dig('data', 'attributes', 'name')).to eq name
    end
  end

  context 'with invalid supplied name' do
    let(:name) { test_data["invalid_name"] }
    it 'returns 404 Record Not Found' do
      expect(analytics_metrics_show.response.code).to eq 404
      expect(analytics_metrics_show.response.body).to match /Record Not Found/
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    it 'returns 403 Forbidden' do
      expect(analytics_metrics_show.response.code).to eql 403
      expect(analytics_metrics_show.response.body).to match /Authorization Failure/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(analytics_metrics_show.response.code).to eql 401
      expect(analytics_metrics_show.response.body).to match /Authentication Failed/
    end
  end

end



