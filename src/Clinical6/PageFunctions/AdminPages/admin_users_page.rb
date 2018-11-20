require_relative '../base_page'

class AdminUsersPage < BasePage

  def self.navigate_to_users_page
    LeftNavigationMenu.navigate_to_admin_users
  end

  def self.invite_new_user(user_email, user_role)
    #Go to Users Page
    navigate_to_users_page
    #Check if user already exists
    unless page.has_selector?(:xpath, "//span[contains(text(), '#{user_email}' )]", wait: 10)
      #Click Invite New User
      click_on 'Invite New User'
      #Prompted Window
      find(:xpath, "//h2[contains(text(),'Invite New User')]", visible: true, wait: 5)
      #Enter Email
      fill_in "email", with:user_email
      #Choose User Role
      find(:css, '.mat-select-value span', text: 'User Role', wait: 5).click
      find(:css, 'mat-option>span', text: /^#{user_role}$/i, wait: 5 ).click
      #Click Send Invitation
      click_button "Send Invitation"
      sleep(5)
    end
  end

  def self.view_user_profile(user_email)
    #Go to Users Page
    navigate_to_users_page
    #Click a user listed in table
    find(:xpath, "//datatable-body-cell/div/span", text: "#{user_email}", wait: 10).click
    #Click Account Details tab
    find(:id, "mat-tab-label-0-1", wait: 5).click
    #Click Personal Information tab
    find(:id, "mat-tab-label-0-0", wait: 5).click
  end

  def self.update_user_profile(user_email)
    #Go to Users Page
    navigate_to_users_page
    #Click a user listed in table
    find(:xpath, "//datatable-body-cell/div/span", text: "#{user_email}", wait: 10).click
    #Update on Personal Information tab
    # First Name
    fill_in "First Name", with: 'autotest'
    #Last Name
    fill_in "Last Name", with: 'autotest'
    #Gender
    find(:css, '.mat-select-value span', text: 'Gender', wait: 5).click
    find(:css, 'mat-option>span', text: 'Male', wait: 5 ).click
    #Preferred Language
    find(:css, '.mat-select-value span', text: 'Preferred Language', wait: 5).click
    find(:css, 'mat-option>span', text: 'English', wait: 5 ).click
    #Time Zone
    find(:css, '.mat-select-value span', text: 'Time Zone', wait: 5).click
    find(:css, 'mat-option>span', text: 'America/Adak', wait: 5 ).click
    #Date
    find(:xpath, '//mat-datepicker-toggle/button', wait: 5).click
    find(:xpath, '//mat-month-view//div', text: '13', wait: 5 ).click
    #Update button
    click_button "Update"
    sleep(5)
  end

  def self.disable_user(user_email)
    #Go to Users Page
    navigate_to_users_page
    #Click a user listed in table
    find(:xpath, "//datatable-body-cell/div/span", text: "#{user_email}", wait: 10).click
    #Click Disable User
    click_button "Disable User"
    #Check dialog pops
    find(:xpath, "//mat-dialog-content", text: "Disable this user?", visible: true, wait: 5)
    #Click Disable
    click_button "Disable"
    sleep(5)
  end

  def self.enable_user(user_email)
    #Go to Users Page
    navigate_to_users_page
    #Click a user listed in table
    find(:xpath, "//datatable-body-cell/div/span", text: "#{user_email}", wait: 10).click
    #Click Enable User
    click_button "Enable User"
    sleep(5)
  end


end