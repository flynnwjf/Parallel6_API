require_relative '../../spec_helper'


describe 'Admin > User Roles', type: :feature, js: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:url) { env_info["full_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "user_role_tests" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'verify user role exists' do

    LoginPage.login_with_credentials(url, user_email, user_password)
    expect(AdminUserRolesPage.check_if_user_role_exists('AutomationTestRole1')).to be true

  end

  it 'Able to update user role name' do

    user_role1 = 'AutomationTestRole1'
    user_role2 = 'AutomationTestRole2'

    LoginPage.login_with_credentials(url, user_name, user_password)

    #if the user role doesn't exist use the second option
    #todo: add a third flag to see if a new role needs to be created (neither user_role1 or user role 2 exist)
    unless AdminUserRolesPage.check_if_user_role_exists(user_role1)
      user_role1, user_role2 = user_role2, user_role1 #switch which variable gets changed from first
    end

    AdminUserRolesPage.update_user_role_details(user_role1, user_role2)
    expect(page).to have_content("The user role details have been successfully updated.")

    AdminUserRolesPage.update_user_role_details(user_role2, user_role1)
    expect(page).to have_content("The user role details have been successfully updated.")

  end

  it 'Able to add and modify role permissions' do


    LoginPage.login_with_credentials(url, user_email, user_password)

    AdminUserRolesPage.update_user_role_permissions('AutomationTestRole1', 'Consent', true, true, false, true)


  end

  it 'Removes all permissions' do
    LoginPage.login_with_credentials(url, user_name, user_password)

    AdminUserRolesPage.update_user_role_permissions('AutomationTestRole1', 'Consent', true, true, false, true)
    AdminUserRolesPage.update_user_role_permissions('AutomationTestRole1', 'test', false, true, false, true)


    AdminUserRolesPage.update_user_remove_all_role_permissions('AutomationTestRole1')
  end




end
