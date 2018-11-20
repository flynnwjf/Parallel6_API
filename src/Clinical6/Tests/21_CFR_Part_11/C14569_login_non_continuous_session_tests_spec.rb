require_relative '../../../spec_helper'

describe 'C14569 https://parallel6.testrail.com/index.php?/cases/view/14569', type: :feature, js: true do

  TestName = "C14569"
  let(:url) {DataHandler.get_test_data(TestName,TestEnv, "url")}
  let(:screenshot_path) {DataHandler.get_test_data(TestName,TestEnv, "screenshot_path")}
  let(:user_name) {DataHandler.get_test_data(TestName,TestEnv,"user_name")}
  let(:user_password) {DataHandler.get_test_data(TestName,TestEnv,"user_password")}


  context 'Non-continuous signing sessions shall require' do
    it 'entry of both components (user ID and password) for each signing' do
      #Login Platform
      LoginPage.login_platform(url, user_name, user_password)
      expect(page).to have_content('Signed in successfully')
      page.save_screenshot(screenshot_path + 'NavigateToHome.png')
      #Logout Platform
      LoginPage.logout_platform(user_name)
      #Navigate to Platform Login Page
      LoginPage.visit_url(url)
      #Check components
      expect(page).to have_xpath('//*[@id="user_login"]')
      expect(page).to have_xpath('//*[@id="user_password"]')
      page.save_screenshot(screenshot_path + 'LogOutNavigateAgain.png')
    end
  end

end

