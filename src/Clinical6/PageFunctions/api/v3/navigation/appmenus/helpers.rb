require_relative "../../../base_api"

module V3
  module Navigation
    module AppMenu
      class MenuHelper
        attr_reader :token, :user_email, :base_url
        def initialize(token, user_email, base_url)
          @token = token
          @user_email = user_email
          @base_url = base_url
        end

        def delete_all_menus(cascade)
          menu_resp = V3::Navigation::AppMenus::Index.new(@token, @user_email, @base_url)
          JSON.parse(menu_resp.response.body)['data'].each do |menu|
            id = menu.dig('id').to_i
            puts "Delete Menu ID: #{id}"
            V3::Navigation::AppMenus::Delete.new(@token, @user_email, @base_url, id, cascade).response
          end
        end

      end
    end
  end
end