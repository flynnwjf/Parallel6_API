require_relative '../../../../../../../src/spec_helper'

describe 'Get V3/navigation/app_menus' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "navigation_appmenus_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:navigation_appmenus_index) { V3::Navigation::AppMenus::Index.new(token, user_email, base_url) }

  context 'with valid user' do

    let(:count) { navigation_appmenus_index.count }
    it 'returns 200 code and shows app menus' do
      navigation_appmenus_index = V3::Navigation::AppMenus::Index.new(token, user_email, base_url)
      if count.zero?
        flow_process_id = 1
        title = "some-title"
        create_app_menu = V3::Navigation::AppMenus::Create.new(token, user_email, base_url, flow_process_id, title)
        expect(create_app_menu.response.code).to eq 201
        # id = create_app_menu.id
        created_id = create_app_menu.id
        navigation_appmenus_index = V3::Navigation::AppMenus::Index.new(token, user_email, base_url)
      end


      expect(navigation_appmenus_index.response.code).to eq 200
      expect(JSON.parse(navigation_appmenus_index.response.body).dig("data", 0,"id")).not_to eq nil
      expect(JSON.parse(navigation_appmenus_index.response.body).dig("data", 0,"type")).to eq "navigation__app_menus"

      if created_id
        delete_app_menu = V3::Navigation::AppMenus::Delete.new(token, user_email, base_url, created_id)
        expect(delete_app_menu.response.code).to eq 204
      end

    end
  end

  context 'with invalid user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(navigation_appmenus_index.response.code).to eql 401
      expect(navigation_appmenus_index.response.body).to match /Authentication Failed/
    end
  end

end

