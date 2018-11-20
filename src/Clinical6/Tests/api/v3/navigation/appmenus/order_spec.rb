require_relative '../../../../../../../src/spec_helper'

describe 'Post V3/navigation/app_menus/order' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "navigation_appmenus_order" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:navigation_appmenus_index) { V3::Navigation::AppMenus::Index.new(token, user_email, base_url) }
  let(:count) { navigation_appmenus_index.count }
  let(:id) { navigation_appmenus_index.id }
  let(:navigation_appmenus_order) { V3::Navigation::AppMenus::Order.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 201 code and order app menu' do
      cleanup = false
      if count == 0
        cleanup = true
        flow_process_id = 1
        title = "some-title"
        create_app_menu = V3::Navigation::AppMenus::Create.new(token, user_email, base_url, flow_process_id, title)
        expect(create_app_menu.response.code).to eq 201
        id = create_app_menu.id
        navigation_appmenus_order = V3::Navigation::AppMenus::Order.new(token, user_email, base_url, id)
      end

      expect(navigation_appmenus_order.response.code).to eq 201
      expect(JSON.parse(navigation_appmenus_order.response.body).dig("data", count-1, "id")).to eq id
      expect(JSON.parse(navigation_appmenus_order.response.body).dig("data", count-1, "attributes", "position").to_s).to eq id


      #cleanup
      if cleanup
        delete_app_menu = V3::Navigation::AppMenus::Delete.new(token, user_email, base_url, id)
        expect(delete_app_menu.response.code).to eq 204
      end

    end
  end

  context 'with invalid id' do
    let(:id) {test_data["invalid_id"]}
    it 'returns 422 error & Invalid parameters message in body' do
      expect(navigation_appmenus_order.response.code).to eq 422
      expect(navigation_appmenus_order.response.body).to match /Invalid parameters/
    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:id) {test_data["id"]}
    it 'returns 401 error' do
      expect(navigation_appmenus_order.response.code).to eql 401
      expect(navigation_appmenus_order.response.body).to match /Authentication Failed/
    end
  end

end

