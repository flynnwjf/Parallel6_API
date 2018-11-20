require_relative '../../../../../../src/spec_helper'

describe 'Get V3/menus/list' do
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
  let(:type) { pre_test_data["type"] }
  let(:title) { pre_test_data["title"] }
#Test Info
  let(:testname) { "menus_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:menus_create) { V3::Menus::Create.new(token, user_email, base_url, type, title) }
  let(:id) { menus_create.id }
  let(:menus_list) { V3::Menus::List.new(token, user_email, base_url) }

  context 'with valid user' do
    it 'returns 200 status code & shows the list' do
      expect(menus_create.response.code).to eq 201
      expect(menus_list.response.code).to eq 200
      #cleanup
      expect(V3::Menus::Destroy.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:menus_list) { V3::Menus::List.new(token, invalid_user, base_url) }
    it 'returns 401 error' do
      expect(menus_list.response.code).to eq 401
      expect(menus_list.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end
end



