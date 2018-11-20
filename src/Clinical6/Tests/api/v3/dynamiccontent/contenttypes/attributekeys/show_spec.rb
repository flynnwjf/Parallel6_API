require_relative '../../../../../../../../src/spec_helper'

describe 'Get V3/dynamic_content/content_types/:id/dynamic_content/attribute_keys/show' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "dynamiccontent_contenttypes_attributekeys_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:attribute_keys_show) { V3::DynamicContent::ContentTypes::AttributeKeys::Show.new(token, user_email, base_url, id) }

  context 'with valid user and valid content type id' do
    it 'returns 200 status code & shows a content type' do
      expect(attribute_keys_show.response.code).to eq 200

      #TODO: Add dynamic way to create attributes specs so this always passes
      #expect(JSON.parse(attribute_keys_show.response).dig('data',0,'type')).to eq "dynamic_content__attribute_keys"
      #expect(JSON.parse(attribute_keys_show.response).dig('data',0,'relationships','content_type','data','id')).to eq id
      #expect(JSON.parse(attribute_keys_show.response).dig('data',0,'relationships','content_type','data','type')).to eq "dynamic_content__content_types"
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid content type id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(attribute_keys_show.response.code).to eq 404
      expect(attribute_keys_show.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:attribute_keys_show) { V3::DynamicContent::ContentTypes::AttributeKeys::Show.new(token, invalid_user, base_url, id) }
    it 'returns 401 error' do
      expect(attribute_keys_show.response.code).to eq 401
      expect(attribute_keys_show.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



