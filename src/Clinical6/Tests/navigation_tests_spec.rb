require_relative '../../spec_helper'


describe 'Attempting to login with', type: :feature, js: true do

  TestName = "navigation_tests"
  let(:url) {DataHandler.get_env_url(TestEnv)}
  let(:user_name) {DataHandler.get_test_data(TestName,TestEnv,"user_name")}
  let(:user_password) {DataHandler.get_test_data(TestName,TestEnv,"user_password")}


  context 'Logged In user ' do

    it 'successfully navigate to all pages' do

      #Home Page
      LoginPage.login_with_credentials(url, user_name, user_password)
      expect(page).to have_content ('Home')

      #User Roles Page
      AdminUserRolesPage.navigate_to_user_roles_page
      expect(page).to have_content('User Roles')

      StartupPage.navigate_to_startup_page
      expect(page).to have_content("startup works!")

      AnalyzePage.navigate_to_analyze_page
      expect(page).to have_content("analyze works!")

      FormsPage.navigate_to_enroll_forms_page
      expect(page).to have_content("Forms")

      StudyInformationPage.navigate_to_engage_study_information_page
      expect(page).to have_content("Study Information")

      ConsultPage.navigate_to_consult_page
      expect(page).to have_content("consult works!")

      RecordPage.navigate_to_record_page
      expect(page).to have_content("record works!")

      CapturePage.navigate_to_capture_page
      expect(page).to have_content("capture works!")

    end

    it 'verifies emails' do
      #email = Mailinator::Email.get('qatestparallel01@mailinator.com')
      #email_address = 'p6'

      #puts Mailinator.get_last_email_body(email_address, "invitation_token=", '\">Accept Invitation')
      #puts Mailinator.get_last_email_body(email_address, 'href=\"', '\">Accept Invitation')

      email_address = 'p61'
      puts Mailinator.get_last_email_body(email_address, 'Message Start:', 'Message End.')


    end
  end
end
