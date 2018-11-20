require_relative '../../spec_helper'

describe 'Attempting to login with', type: :feature, js: true do

  TestName = "login_tests"
  let(:url) {DataHandler.get_env_url(TestEnv)}
  let(:screenshot_path) {DataHandler.get_test_data(TestName,TestEnv, "screenshot_path")}
  let(:user_name) {DataHandler.get_test_data(TestName,TestEnv,"user_name")}
  let(:user_password) {DataHandler.get_test_data(TestName,TestEnv,"user_password")}
  let(:invalid_user) {DataHandler.get_test_data(TestName,TestEnv,"invalid_user")}
  let(:invalid_password_1) {DataHandler.get_test_data(TestName,TestEnv,"invalid_password_1")}
  let(:invalid_password_2) {DataHandler.get_test_data(TestName,TestEnv,"invalid_password_2")}


  context 'Existing user' do

    context 'and valid password' do
      it 'successfully logs in' do
        LoginPage.login_with_credentials(url,user_name, user_password)
        expect(page).to have_content ('Home')
        page.save_screenshot(screenshot_path + 'ExistingUserValidAccess.png')
      end
    end

    context 'and invalid password' do
      it 'displays invalid credentials' do
        #attempt to login w/ incorrect credentials
        LoginPage.login_with_credentials(url, user_name, invalid_password_1, true)
        expect(page).to have_content("Invalid credentials. Please try again.")
        page.save_screenshot(screenshot_path + 'ExistingUserInvalidAccess.png')
        #login with correct credentials so user doesn't get locked out

        LoginPage.login_with_credentials(url, user_name, user_password)
      end
    end

  end

  context 'Non Existant user' do
    it 'displays invalid credentials' do
      LoginPage.login_with_credentials(url, invalid_user, invalid_password_2, true)
      expect(page).to have_content("Invalid credentials. Please try again.")
      page.save_screenshot(screenshot_path + 'NonExistingUserDeniedAccess.png')
    end
  end

end

