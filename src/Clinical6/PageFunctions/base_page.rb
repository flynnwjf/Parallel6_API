require 'capybara/dsl'

class BasePage
  extend Capybara::DSL
  extend RSpec::Matchers

  #Left Navigation Menu
  #todo: define difference between different environment navigation elements
  class LeftNavigationMenu < BasePage

    def self.navigate_to_home
      find(:xpath, '//img[@class="logo-nav"]', wait: 5).click
    end

    def self.navigate_to_admin_user_roles
      #if not already on the page
      if page.has_no_selector?(:css, '.main-container mat-toolbar>span', text: 'User Roles', wait: 5)
        #if the menu isn't already expended
        if page.has_no_selector?(:css, 'mat-nav-list div>span', text: 'User Roles', wait: 5)
          #navigation difference
          if page.has_selector?(:css, 'mat-nav-list div>span', text: 'Admin', wait: 5)
            find(:css, 'mat-nav-list div>span', text: 'Admin').click
          else
            find(:css, 'mat-nav-list div>span', text: 'User Management').click
          end
        end
        #if the menu is expanded, click User Roles
        find(:css, 'mat-nav-list div>span', text: 'User Roles').click
      end
    end

    def self.navigate_to_admin_users
      #if not already on the page
      unless (page.current_path.include? "users")
        #if the menu isn't already expended
        if page.has_no_selector?(:css, 'mat-nav-list div>span', text: 'Users', wait: 5)
          #navigation difference
          if page.has_selector?(:css, 'mat-nav-list div>span', text: 'Admin', wait: 5)
            find(:css, 'mat-nav-list div>span', text: 'Admin').click
          else
            find(:css, 'mat-nav-list div>span', text: 'User Management').click
          end
        end
        #if the menu is already expanded
        find(:css, 'mat-nav-list div>span', text: 'Users', wait: 5).click
      end
    end


    def self.navigate_to_startup
      #if not already on the page
      unless (page.current_path.include? "startup")
        find(:css, 'mat-nav-list div>span', text: 'Startup').click
      end
    end

    def self.navigate_to_analyze
      #if not already on the page
      unless (page.current_path.include? "analyze")
        find(:css, 'mat-nav-list div>span', text: 'Analyze').click
      end
    end

    def self.navigate_to_enroll_forms
      #if not already on the page
      unless (page.current_path.include? "forms")

        #if the menu isn't already expended
        if page.has_no_selector?(:css, 'mat-nav-list div>span', text: 'Forms', wait: 5)
          find(:css, 'mat-nav-list div>span', text: 'Enroll').click
        end

        find(:css, 'mat-nav-list div>span', text: 'Forms').click
      end
    end


    def self.navigate_to_engage_study_information
      #if not already on the page
      unless (page.current_path.include? "study-information")

        #if the menu isn't already expended
        if page.has_no_selector?(:css, 'mat-nav-list div>span', text: 'Study Information', wait: 5)
          find(:css, 'mat-nav-list div>span', text: 'Engage').click
        end

        find(:css, 'mat-nav-list div>span', text: 'Study Information').click
      end
    end

    def self.navigate_to_consult
      #if not already on the page
      unless (page.current_path.include? "consult")
        find(:css, 'mat-nav-list div>span', text: 'Consult').click
      end
    end

    def self.navigate_to_record
      #if not already on the page
      unless (page.current_path.include? "record")
        find(:css, 'mat-nav-list div>span', text: 'Record').click
      end
    end

    def self.navigate_to_capture
      #if not already on the page
      unless (page.current_path.include? "capture")
        find(:css, 'mat-nav-list div>span', text: 'Capture').click
      end
    end

  end
end