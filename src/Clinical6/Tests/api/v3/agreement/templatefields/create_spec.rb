require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/agreement/templatefields/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "agreement_templatesfields_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:field_name) { "TestField" + Time.new.strftime("%Y-%m-%d %H:%M:%S") }

#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let (:templates_fields_create) { V3::Agreement::TemplateFields::Create.new(token, user_email, base_url, field_name) }
  let (:created_id) { templates_fields_create.id }


  context 'with valid user and data' do
    it 'responds with 201 and creates a template field' do
      expect(templates_fields_create.response.code).to eq 201
      expect(created_id.to_i).to be > 1

      # cleanup
      expect((V3::Agreement::TemplateFields::Destroy.new(token, user_email, base_url, created_id)).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:user_email) { test_data["invalid_name"] }
    it 'returns 401 error' do
      expect(templates_fields_create.response.code).to eq 401
      expect(templates_fields_create.response.body).to match /Authentication Failed/
    end
  end

end



