require_relative '../../../spec_helper'

describe 'C14279 https://parallel6.testrail.com/index.php?/cases/view/14279', type: :feature, js: true do

  TestName = "C14279"
  let(:'test_data.json'){}
  let(:test_env){DataHandler.get_env(TestEnv)}
  let(:url) {test_env[:full_url]}
  let(:screenshot_path) {DataHandler.get_test_data(TestName,TestEnv, "screenshot_path")}
  let(:user_name) {DataHandler.get_env_user(TestEnv,:super_user)[:email]}
  let(:user_password) {DataHandler.get_env_user(TestEnv,:password)}


  context 'The System shall define a period of inactive time' do
    it 'after which a session must be considered non-continuous' do
      #Login
      LoginPage.login_with_credentials(url, user_name, user_password)
      expect(page).to have_content('Home')
      #Navigate to Users page
      AdminUsersPage.navigate_to_users_page
      #Navigate to Home page
      LoginPage.navigate_to_homepage
      page.save_screenshot(screenshot_path + 'NavigateToHome.png')
      #Wait for session timeout (+15mins)
      sleep(60*20)
      #Check whether it jumps to login page automatically after session timeout
      if page.has_xpath?('//img[@class="logo-nav"]')
        LoginPage.navigate_to_homepage
      end
      #Check whether it jumps to login page
      expect(page).to have_content('Your session has expired. Please login again.')
      expect(page).to have_content('Forgot Password?')
      page.save_screenshot(screenshot_path + 'SessionTimeOut.png')
    end
  end

end

