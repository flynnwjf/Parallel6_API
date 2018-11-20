require_relative '../../../../../../src/spec_helper'

describe 'Get V3/timezones' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Test Info
  let(:testname) { "get_timezones" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
   let(:timezones){ V3::Timezones::Index.new(base_url)}

  context 'with valid user' do
    it 'returns 200 and shows timezones' do
      expect(timezones.response.code).to eq 200
      expect(JSON.parse(timezones.response.body).dig("data", 0,"type")).to eq "timezones"
    end
  end

end

