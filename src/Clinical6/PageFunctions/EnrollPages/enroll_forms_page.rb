require_relative '../base_page'

class FormsPage < BasePage


  def self.navigate_to_enroll_forms_page
    #click on enroll_forms_page
    LeftNavigationMenu.navigate_to_enroll_forms
  end

end
