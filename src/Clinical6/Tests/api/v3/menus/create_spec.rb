require_relative '../../../../../../src/spec_helper'

describe 'Post V3/menus/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "menus_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:menus_create) { V3::Menus::Create.new(token, user_email, base_url, type, title) }
  let(:created_id) { menus_create.id }

  context 'with valid user and valid title' do
    it 'returns 201 status code & creates a menu' do
      expect(menus_create.response.code).to eq 201
      expect(created_id.to_i).to be >=1
      expect(JSON.parse(menus_create.response).dig('data','type')).to eq type
      expect(JSON.parse(menus_create.response).dig('data', 'attributes','title')).to eq title
      puts "menus_create_response_body: " + menus_create.response.body.to_s
      #cleanup
      expect(V3::Menus::Destroy.new(token, user_email, base_url, created_id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid title' do
    let(:title) { test_data["invalid_title"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(menus_create.response.code).to eq 422
      expect(menus_create.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:menus_create) { V3::Menus::Create.new(token, invalid_user, base_url, type, title) }
    it 'returns 401 error' do
      expect(menus_create.response.code).to eq 401
      expect(menus_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



