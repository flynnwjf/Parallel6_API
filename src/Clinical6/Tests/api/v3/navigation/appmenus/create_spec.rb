require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/navigation/app_menus' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "navigation_appmenus_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:title) { "Test- " + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:flow_process_id) { V3::DataCollection::FlowProcesses::Index.new(token, user_email, base_url).id }
  let(:navigation_appmenus_create) { V3::Navigation::AppMenus::Create.new(token, user_email, base_url, flow_process_id, title) }

  context 'with valid user' do
    it 'returns 201 code and creates app menu' do
      expect(navigation_appmenus_create.response.code).to eq 201
      expect(JSON.parse(navigation_appmenus_create.response.body).dig("data", "id")).not_to eq nil
      expect(JSON.parse(navigation_appmenus_create.response.body).dig("data", "type")).to eq "navigation__app_menus"
      expect(JSON.parse(navigation_appmenus_create.response.body).dig("data", "attributes", "title")).to eq title
      #Clean Up
      id = JSON.parse(navigation_appmenus_create.response.body).dig("data", "id")
      expect(V3::Navigation::AppMenus::Delete.new(token, user_email, base_url, id).response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:flow_process_id) {test_data["invalid_id"]}
    it 'returns 422 error & Invalid parameters message in body' do
      expect(navigation_appmenus_create.response.code).to eq 422
      expect(navigation_appmenus_create.response.body).to match /Invalid parameters/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:flow_process_id) {test_data["id"]}
    it 'returns 401 error' do
      expect(navigation_appmenus_create.response.code).to eql 401
      expect(navigation_appmenus_create.response.body).to match /Authentication Failed/
    end
  end

end

