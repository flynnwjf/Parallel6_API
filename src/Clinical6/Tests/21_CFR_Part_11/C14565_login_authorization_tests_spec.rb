require_relative '../../../spec_helper'

#https://parallel6.testrail.com/index.php?/cases/view/14565
describe 'C14565 Authentication - Login ', type: :feature, js: true do

  #Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:url) {env_info["full_url"] }

  #Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) {env_user["email"] }
  let(:user_password) {env_user["password"] }

  #Test Info
  let(:testname) {"C14565"}
  let(:test_info) { DataHandler.get_test_data(testname) }
  let(:screenshot_path) {test_info["screenshot_path"] }


  context 'with correct credentials ' do
    it 'a user is logged in' do
      LoginPage.login_with_credentials(url, user_email, user_password)
      expect(page).to have_content ('Home')
      page.save_screenshot(screenshot_path + 'ExistingUserValidAccess.png')
    end
  end

  context 'with wrong password' do
    let(:user_password) { test_info["invalid_password_1"] }
    it 'system denies access' do
      puts user_email
      puts user_password
      #Login w/ incorrect credentials
      LoginPage.login_with_credentials(url, user_email, user_password, true)
      expect(page).to have_content("Invalid credentials. Please try again.")
      page.save_screenshot(screenshot_path + 'ExistingUserInvalidAccess.png')

      #login with valid password as not to lockout account
      let(:user_password) {env_user["password"] }
      LoginPage.login_with_credentials(url, user_email, user_password)
    end
  end

  context 'when non-existant user attempts to login' do
    let(:user_email){test_info["invalid_user"]}
    it 'system denies access' do
      puts user_email
      puts user_password

      #Login w/ incorrect credentials
      LoginPage.login_with_credentials(url, user_email, user_password, true)
      expect(page).to have_content("Invalid credentials. Please try again.")
      page.save_screenshot(screenshot_path + 'NonExistingUserDeniedAccess.png')
    end
  end


end


