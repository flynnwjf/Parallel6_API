require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Patch V3/agreement/templates/:id/update' do
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
  let(:pre_type) { pre_test_data["type"] }
  let(:pre_template_name) { pre_test_data["template_name"] + DateTime.now.strftime('_%F_%Q').to_s }
#Test Info
  let(:testname) { "agreement_templates_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:template_name) { test_data["template_name"] + DateTime.now.strftime('_%F_%Q').to_s }
  let(:description) { test_data["description"] + DateTime.now.strftime('_%F_%Q').to_s}
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:templates_create) { V3::Agreement::Templates::Create.new(token, user_email, base_url, pre_type, pre_template_name) }
  let(:id) { templates_create.id }
  let(:templates_update) { V3::Agreement::Templates::Update.new(token, user_email, base_url, id, type, template_name, description) }

  context 'with valid user and valid template name' do
    it 'returns 200 status code & updates the agreement template' do
        expect(templates_create.response.code).to eq 200
        expect(templates_update.response.code).to eq 200
        expect(JSON.parse(templates_update.response).dig('data','id')).to eq id
        expect(JSON.parse(templates_update.response).dig('data','type')).to eq type
        expect(JSON.parse(templates_update.response).dig('data','attributes',"template_name")).to eq template_name
        expect(JSON.parse(templates_update.response).dig('data','attributes',"description")).to eq description
        puts "response_body: " + templates_update.response.body.to_s
        #cleanup
        expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
      end
  end

  context 'with valid user and invalid template name' do
    let(:template_name) { test_data["invalid_template_name"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(templates_create.response.code).to eq 200
      expect(templates_update.response.code).to eq 422
      expect(templates_update.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:templates_update) { V3::Agreement::Templates::Update.new(token, invalid_user, base_url, id, type, template_name, description) }
    it 'returns 401 error' do
      expect(templates_update.response.code).to eq 401
      expect(templates_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid agreement template id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(templates_update.response.code).to eq 404
      expect(templates_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



