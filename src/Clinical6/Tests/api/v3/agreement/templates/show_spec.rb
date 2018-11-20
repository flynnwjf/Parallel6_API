require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Get V3/agreement/templates/:id/show' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "agreement_templates_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:template_name) { pre_test_data["template_name"] + DateTime.now.strftime('_%F_%Q').to_s }
#Test Info
  let(:testname) { "agreement_templates_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:templates_create) { V3::Agreement::Templates::Create.new(token, user_email, base_url, type, template_name) }
  let(:id) { templates_create.id }
  let(:templates_show) { V3::Agreement::Templates::Show.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 status code & shows the agreement template' do
      expect(templates_create.response.code).to eq 200
      expect(templates_show.response.code).to eq 200
      expect(JSON.parse(templates_show.response).dig('data', 'id')).to eq id
      puts "response_body: " + templates_show.response.body.to_s
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
     let(:invalid_user) { test_data["invalid_name"] }
     let(:templates_show) { V3::Agreement::Templates::Show.new(token, invalid_user, base_url, id) }
     it 'returns 401 error' do
      expect(templates_show.response.code).to eq 401
      expect(templates_show.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid agreement template id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(templates_show.response.code).to eq 404
      expect(templates_show.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



