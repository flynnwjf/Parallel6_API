require_relative '../base_page'

class AdminUserRolesPage < BasePage

  def self.navigate_to_user_roles_page
    LeftNavigationMenu.navigate_to_admin_user_roles
  end

  def self.check_if_user_role_exists(user_role_name)
    navigate_to_user_roles_page
    page.has_selector?(:xpath, "//span[contains(text(), '#{user_role_name}' )]", wait: 5)
  end

  def self.add_new_user_role(user_role_name)
    navigate_to_user_roles_page
    #Click Add New User Role
    click_button 'Add New User Role'
    #Prompted Window
    find(:xpath, "//h2[contains(text(),'Add New User Role')]", visible: true, wait: 5)
    #Enter Role Name
    fill_in 'Role Name', with: user_role_name
    #Click Add User Role
    click_button 'Add User Role'
    #Check successful message
    page.has_text?('User role was successfully added.', wait: 5)
  end

  def self.view_user_role_details(user_role_name)
    navigate_to_user_roles_page
    #Click a user role
    find(:xpath, "//span[contains(text(), '#{user_role_name}')]", wait: 5).click
    #Check User Role Details page is displayed
    page.has_text?('User Role Details', wait: 5)
  end

  def self.add_permission(user_role_name, user_role_permission_name)
    #Go to User Role Details page and remove specific permission if it is already existing
    remove_specific_permission(user_role_name, user_role_permission_name)
    #Click + Add Permissions
    click_button '+ Add Permissions'
    #Prompted Window
    find(:xpath, "//h3[contains(text(),'Add Permissions')]", visible: true, wait: 5)
    find(:css, 'mat-select[aria-disabled="false"]', visible: true, wait: 5)
    #Select Content to open dropdown list
    find(:css, '.mat-select-value span', text: 'Select Content', wait: 3).click
    #Choose permission that will be added
    find(:css, 'mat-option>span', text: /^#{user_role_permission_name}$/i, wait: 5 ).click
    #Close dropdown list
    page.driver.browser.action.send_keys(:tab).perform
    #Click Add Permission
    click_button 'Add Permission'
  end

  def self.update_user_role_details(user_role_name, new_user_role_name)
    #Go to User Role Details page
    view_user_role_details(user_role_name)
    #Edit name of user role
    fill_in 'Name', with: new_user_role_name
    #Click update button
    click_on 'Update'
    #Check successful message
    page.has_text?('The user role details have been successfully updated', wait: 5)
  end

  def self.update_user_role_permissions(user_role_name, user_role_permission_name, create, view, edit, delete)
    #Go to User Role Details page
    view_user_role_details(user_role_name)
    #Add Permission
    add_permission(user_role_name, user_role_permission_name)
    #Update detailed permissions
    if create
      page.find(:css, 'datatable-body-cell:nth-child(1)', text: "#{user_role_permission_name}").find(:xpath, "(//mat-checkbox[@name='checkbox'])[1]").click
    end
    if view
      page.find(:css, 'datatable-body-cell:nth-child(1)', text: "#{user_role_permission_name}").find(:xpath, "(//mat-checkbox[@name='checkbox'])[2]").click
    end
    if edit
      page.find(:css, 'datatable-body-cell:nth-child(1)', text: "#{user_role_permission_name}").find(:xpath, "(//mat-checkbox[@name='checkbox'])[3]").click
    end
    if delete
      page.find(:css, 'datatable-body-cell:nth-child(1)', text: "#{user_role_permission_name}").find(:xpath, "(//mat-checkbox[@name='checkbox'])[4]").click
    end
  end

  def self.remove_all_role_permissions(user_role_name)
    #Go to User Role Details page
    view_user_role_details(user_role_name)
    #Remove all permissions
    page.all(:css, 'datatable-body-cell button').each do |remove_icon|
      remove_icon.click
      click_button 'Remove'
    end
  end

  def self.remove_specific_permission(user_role_name, user_role_permission_name)
    #Go to User Role Details page
    view_user_role_details(user_role_name)
    #Remove existing one if the permission is already there
    if page.has_selector?(:css, 'datatable-body-cell:nth-child(1)', text: "#{user_role_permission_name}", wait: 5)
      page.find(:css, 'datatable-body-cell:nth-child(1)', text: "#{user_role_permission_name}").find(:xpath, '..').find(:css, 'button').click
      click_button 'Remove'
    end
  end

end