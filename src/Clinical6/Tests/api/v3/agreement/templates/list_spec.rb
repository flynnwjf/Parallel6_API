require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Get V3/agreement/templates/list' do
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
  let(:testname) { "agreement_templates_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
#let(:templates_create) { V3::Agreement::Templates::Create.new(token, user_email, base_url, type, template_name) }
  let(:templates_list) { V3::Agreement::Templates::List.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code & lists all the agreement templates', :core_test do

      #create a template if none exist
      @cleanup = false
      if (templates_list.response.body.size < 100)
        expect((V3::Agreement::Templates::Create.new(token, user_email, base_url, type, template_name)).code).to eq 200
        let(:templates_list) { V3::Agreement::Templates::List.new(token, user_email, base_url)}
        @cleanup = true
      end

      expect(templates_list.response.code).to eq 200
      expect(JSON.parse(templates_list.response).dig('data', 0, 'type')).to eq type

      #cleanup if needed
      if (@cleanup == true)
        expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
      end
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:templates_list) { V3::Agreement::Templates::List.new(token, invalid_user, base_url) }
    it 'returns 401 error' do
      expect(templates_list.response.code).to eq 401
      expect(templates_list.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end
end



