require_relative "../../../base_api"

module V3
  module Navigation
    module AppMenus
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "navigation__app_menu",
              "attributes": {
                "title": "#{title}",
                "action": "subcategory"
              },
              "relationships": {
                "action_detail": {
                  "data": {
                    "id": "#{flow_process_id}",
                    "type": "data_collection__flow_process"
                  }
                }
              }
            }
          }
          JSON
        end

        private def post_create
          response = RestClient.post("https://#{@env}/v3/navigation/app_menus", payload.to_json,
                                     {content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email}
          ) {|response, request, result| response}
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :flow_process_id, :title

        def initialize(token, email, environment, flow_process_id, title)
          @email = email
          @env = environment
          @token = token
          @flow_process_id = flow_process_id
          @title = title
        end

        def response
          @response ||= post_create
        end

        def id
          @id ||= JSON.parse(response).dig("data", "id")
        end

      end
    end
  end
end
