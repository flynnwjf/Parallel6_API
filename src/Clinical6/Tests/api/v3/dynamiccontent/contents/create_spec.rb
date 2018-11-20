require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/dynamiccontent/contents/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:env_mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_user_email) { env_mobile_user["email"] }
  let(:mobile_user_password) { env_mobile_user["password"] }
  let(:device_id) { env_mobile_user["device_id"]}
#Test Info
  let(:testname) { "dynamiccontent_contents_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:content_type_id) { test_data["content_type_id"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:mobile_id) { V3::MobileUser::Session::Create.new(mobile_user_email, mobile_user_password, base_url, device_id).mobile_user_id}
  let(:contents_create) { V3::DynamicContent::Contents::Create.new(token, user_email, base_url, type, content_type_id, mobile_id) }
  let(:created_id) { contents_create.id }

  context 'with valid user and valid content type id' do
    it 'returns 201 status code & create a content' do
      expect(contents_create.response.code).to eq 201
      expect(created_id.to_i).to be >=1
      expect(JSON.parse(contents_create.response).dig('data','type')).to eq type
      expect(JSON.parse(contents_create.response).dig('data','relationships','content_type','data','id')).to eq content_type_id
      puts "create_response_body: "+ contents_create.response.to_s
      #cleanup
      expect(V3::DynamicContent::Contents::Destroy.new(token, user_email, base_url, created_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid content type id' do
    let(:content_type_id) { test_data["invalid_content_type_id"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(contents_create.response.code).to eq 422
      expect(contents_create.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:contents_create) { V3::DynamicContent::Contents::Create.new(token, invalid_user, base_url, type, content_type_id) }
    it 'returns 401 error' do
      expect(contents_create.response.code).to eq 401
      expect(contents_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



