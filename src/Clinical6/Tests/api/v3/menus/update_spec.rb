require_relative '../../../../../../src/spec_helper'

describe 'Patch V3/menus/:id/update' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "menus_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:pre_type) { pre_test_data["type"] }
  let(:pre_title) { pre_test_data["title"] }
#Test Info
  let(:testname) { "menus_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:menus_create) { V3::Menus::Create.new(token, user_email, base_url, pre_type, pre_title) }
  let(:id) { menus_create.id }
  let(:menus_update) { V3::Menus::Update.new(token, user_email, base_url, id, type, title) }

  context 'with valid user and valid title' do
    it 'returns 200 status code & updates a menu' do
      expect(menus_create.response.code).to eq 201
      expect(menus_update.response.code).to eq 200
      expect(JSON.parse(menus_update.response).dig('data','id')).to eq id
      expect(JSON.parse(menus_update.response).dig('data','type')).to eq type
      expect(JSON.parse(menus_update.response).dig('data', 'attributes',"title")).to eq title
      #cleanup
      expect(V3::Menus::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid title' do
    let(:title) { test_data["invalid_title"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(menus_create.response.code).to eq 201
      expect(menus_update.response.code).to eq 422
      expect(menus_update.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Menus::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:menus_update) { V3::Menus::Update.new(token, invalid_user, base_url, id, type, title) }
    it 'returns 401 error' do
      expect(menus_create.response.code).to eq 201
      expect(menus_update.response.code).to eq 401
      expect(menus_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Menus::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(menus_create.response.code).to eq 201
      expect(menus_update.response.code).to eq 404
      expect(menus_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Menus::Destroy.new(token, user_email, base_url, menus_create.id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



