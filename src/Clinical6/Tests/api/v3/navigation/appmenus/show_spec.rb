require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/navigation/app_menus/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "navigation_appmenus_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:navigation_appmenus_index) { V3::Navigation::AppMenus::Index.new(token, user_email, base_url) }
  let(:count) { navigation_appmenus_index.count }
  let(:existing_id) { navigation_appmenus_index.id }
  #let(:navigation_appmenus_show) {V3::Navigation::AppMenus::Show.new(token, user_email, base_url, id)}

  context 'with valid user' do
    it 'returns 200 code and shows app menus' do
      # id = navigation_appmenus_index.id
      if count.zero?
        flow_process_id = 1
        title = "some-title"
        create_app_menu = V3::Navigation::AppMenus::Create.new(token, user_email, base_url, flow_process_id, title)
        expect(create_app_menu.response.code).to eq 201
        # id = create_app_menu.id
        created_id = create_app_menu.id
      end
      #puts id.class

      id = created_id || existing_id

      navigation_appmenus_show = V3::Navigation::AppMenus::Show.new(token, user_email, base_url, id)
      expect(navigation_appmenus_show.response.code).to eq 200
      expect(JSON.parse(navigation_appmenus_show.response.body).dig("data", "id")).to eq id
      expect(JSON.parse(navigation_appmenus_show.response.body).dig("data", "type")).to eq "navigation__app_menus"

      #cleanup
      if created_id
        delete_app_menu = V3::Navigation::AppMenus::Delete.new(token, user_email, base_url, created_id)
        expect(delete_app_menu.response.code).to eq 204
      end
    end
  end

  context 'with invalid id' do
    let(:id) { test_data["invalid_id"] }
    let(:navigation_appmenus_show) { V3::Navigation::AppMenus::Show.new(token, user_email, base_url, id) }
    it 'returns 404 error' do
      expect(navigation_appmenus_show.response.code).to eq 404
      expect(navigation_appmenus_show.response.body).to match /Record Not Found/
    end
  end

  context 'with invalid user' do
    let(:id) { test_data["id"] }
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:navigation_appmenus_show) { V3::Navigation::AppMenus::Show.new(token, user_email, base_url, id) }
    it 'returns 401 error' do
      expect(navigation_appmenus_show.response.code).to eql 401
      expect(navigation_appmenus_show.response.body).to match /Authentication Failed/
    end
  end

end

