require_relative '../../../../../../src/spec_helper'

describe 'Post V3/devices/create' do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Test Info
  let(:testname) { "devices_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:mobile_application_key) { test_data["mobile_application_key"] }
#Requests
  let(:devices_create) { V3::Devices::Create.new(mobile_application_key, base_url) }

  context 'with valid mobile_application_key' do
    it 'returns 201 status code & creates a device' do
      expect(devices_create.response.code).to eq 201
    end
  end

  context 'with invalid parameter' do
    let(:mobile_application_key) { test_data["invalid_parameter"] }
    it 'returns 422 error' do
      expect(devices_create.response.code).to eq 422
    end
  end

end