require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/agreement/templates/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "agreement_templates_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:template_name) { test_data["template_name"] + DateTime.now.strftime('_%F_%Q').to_s }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:templates_create) { V3::Agreement::Templates::Create.new(token, user_email, base_url, type, template_name) }

  context 'with valid user and valid template name' do
    it 'returns 200 status code & create a agreement template' do
        expect(templates_create.response.code).to eq 200
        expect(JSON.parse(templates_create.response).dig('data','type')).to eq type
        expect(JSON.parse(templates_create.response).dig('data', 'attributes',"template_name")).to eq template_name
        puts "response_body: "+ templates_create.response.to_s
        #cleanup
        expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid template name' do
    let(:template_name) { test_data["invalid_template_name"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(templates_create.response.code).to eq 422
      expect(templates_create.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:templates_create) { V3::Agreement::Templates::Create.new(token, invalid_user, base_url, type, template_name) }
    it 'returns 401 error' do
      expect(templates_create.response.code).to eq 401
      expect(templates_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



