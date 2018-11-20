class LoginPage < BasePage

  def self.navigate_to_homepage
    LeftNavigationMenu.navigate_to_home
  end

  def self.visit_url(url)
    visit url
  end

  def self.login_with_credentials(url, username, password, expect_invalid = false)
    #Navigate to login page
    visit url
    page.current_window.maximize
    #Email
    fill_in 'email', with: username
    #Password
    fill_in 'password', with: password
    #Sign In
    click_on 'Sign In'
    #Either page is invalid or logs in
    unless expect_invalid
      page.has_selector?(:xpath, '//span[contains(text(), "Home")]', wait: 30)
    end
  end

  def self.login_platform(url, username, password, expect_invalid = false)
    #Navigate to login page
    visit url
    page.current_window.maximize
    #Email
    fill_in 'Email or Username', with: username
    #Password
    fill_in 'Password', with: password
    #Sign In
    click_on 'Sign In'
    #Either page is invalid or logs in
    unless expect_invalid
      page.has_text?(:visible, 'Signed in successfully.', wait: 10)
    end
  end

  def self.logout_platform(username)

    #Expand user navigation dropdown
    find(:xpath, "//span[contains(text(), '#{username}')]/i", wait: 2).click
    #Click Logout
    find(:xpath, "//ul//span[contains(text(), 'Logout')]", wait: 2).click
    #Logged Out
    page.has_text?(:visible, 'You need to sign in or sign up before continuing')
  end

end