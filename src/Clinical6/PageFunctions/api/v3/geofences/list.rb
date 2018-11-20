require_relative "../../base_api"

module V3
  module Genfences
     class List < BaseAPI

        private def list_session
          response = RestClient.get("https://#{@env}/v3/geofences",
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :token, :env

        def initialize(token, email, environment)
          @email = email
          @env = environment
          @token = token
        end

        def response
          @response ||= list_session
        end

      end
  end
end
