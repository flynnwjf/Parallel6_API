require_relative "../../../base_api"

module V3
  module DataCollection
    module FlowProcesses
      class Update < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
            {
              "data": {
                  "id": "#{id}",
                  "type": "data_collection__flow_processes",
                  "attributes": {
                     "name": "#{name}",
                     "permanent_link": "#{link}",
                     "description": "#{description}",
                     "consent_credentials": "",
                     "owner_type": "MobileUser",
                     "conditional_paths": ""
                  }
              }
            }
          JSON
        end

        private def patch_update
          response = RestClient.patch("https://#{@env}/v3/data_collection/flow_processes/#{id}",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :id, :link, :description, :name

        def initialize(token, email, environment, id, link, description, name)
          @email = email
          @env = environment
          @token = token
          @id = id
          @link = link
          @description = description
          @name = name
        end

        def response
          @response ||= patch_update
        end

      end
    end
  end
end
