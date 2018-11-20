require_relative '../../../../../../../src/spec_helper'

describe 'Delete V3/navigation/app_menus/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "navigation_appmenus_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:title) { "Test- " + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:flow_process_id) { V3::DataCollection::FlowProcesses::Index.new(token, user_email, base_url).id }
  let(:id) { V3::Navigation::AppMenus::Create.new(token, user_email, base_url, flow_process_id, title).id }
  let(:navigation_appmenus_delete) { V3::Navigation::AppMenus::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 204 code and shows app menus' do
      expect(navigation_appmenus_delete.response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error' do
      expect(navigation_appmenus_delete.response.code).to eq 404
      expect(navigation_appmenus_delete.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:id) { test_data["id"] }
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(navigation_appmenus_delete.response.code).to eql 401
      expect(navigation_appmenus_delete.response.body).to match /Authentication Failed/
    end
  end

end

