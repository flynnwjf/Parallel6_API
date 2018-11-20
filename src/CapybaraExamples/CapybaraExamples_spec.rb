require_relative '../spec_helper'

describe 'My behaviour', type: :feature, js: true do

  it 'does something' do


    expect(page).to have_content('any content')
    expect(page).to have_selector('h1', text: 'Today I Learned')
    expect(page).to have_selector(:xpath, '//span[contains(text(), "Home")]')
    find(:xpath, '//span[contains(text(), "Home")]', wait: 15)

    within 'form' do
      expect(page).to have_selector("input[value='Default copy.']")
    end

    expect(0..1).to cover(order.risk_score)


    super_user = JSON.parse(user_roles.response.body)['data'].find do |user_role|
      # user_role.dig('attributes', 'is_super')
      #user_role.dig('attributes', 'permanent_link') == 'superuser'
    end

    page.has_selector?('li', text: 'ElementText', visible: true)

    #https://devhints.io/capybara
    #https://www.cheatography.com/corey/cheat-sheets/capybara-with-rspec/
    # https://saucelabs.com/resources/articles/selenium-tips-css-selectors
    #
    #
    #
  end
end