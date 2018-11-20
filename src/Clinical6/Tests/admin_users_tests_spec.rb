require_relative '../../spec_helper'



describe 'Admin > Users', type: :feature, js: true do

  TestName = "user_tests"
  let(:url) {DataHandler.get_env_url(TestEnv)}
  let(:user_name) {DataHandler.get_test_data(TestName,TestEnv,"user_name")}
  let(:user_password) {DataHandler.get_test_data(TestName,TestEnv,"user_password")}
  let(:user_email) {DataHandler.get_test_data(TestName,TestEnv,"user_email")}

  it 'invite new user if it is not existing' do

    LoginPage.login_with_credentials(url, user_name, user_password)

    AdminUsersPage.invite_new_user(user_email, 'SuperUser')

    expect(page).to have_content("The invitation was successfully sent.")

  end

  it 'view existing user profile' do

    LoginPage.login_with_credentials(url, user_name, user_password)

    AdminUsersPage.view_user_profile(user_email)

    expect(page).to have_content("Personal Information")
    expect(page).to have_content("Account Details")

  end

  it 'update existing user profile' do

    LoginPage.login_with_credentials(url, user_name, user_password)

    AdminUsersPage.update_user_profile(user_email)

    expect(page).to have_content("The information was successfully updated.")

  end

  it 'disable existing user' do

    LoginPage.login_with_credentials(url, user_name, user_password)

    AdminUsersPage.disable_user(user_email)

    expect(page).to have_content("User #{user_email} is now disabled")

  end

  it 'enable existing user' do

    LoginPage.login_with_credentials(url, user_name, user_password)

    AdminUsersPage.enable_user(user_email)

    expect(page).to have_content("User #{user_email} is now active")

  end


end
