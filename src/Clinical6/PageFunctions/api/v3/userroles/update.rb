require_relative "../../base_api"

module V3
  module UserRoles
    class Update < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "user_roles",
              "attributes": {
                "permanent_link": "#{link}",
                "name": "#{name}",
                "description": "This is a test user role"
              }
            }
          }
          JSON
        end

        private def patch_update
          response = RestClient.patch("https://#{@env}/v3/user_roles/#{@id}", payload.to_json,
                                     { content_type: :json, Accept: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id, :name, :link

        def initialize(token, email, environment, id, name, link)
          @email = email
          @env = environment
          @token = token
          @id = id
          @name = name
          @link = link
        end

        def response
          @response ||= patch_update
        end

    end
  end
end
