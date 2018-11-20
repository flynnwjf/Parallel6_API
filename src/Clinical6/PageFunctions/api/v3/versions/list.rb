require_relative "../../base_api"

module V3
  module Versions
      class List < BaseAPI

        private def get_list
          response = RestClient.get("https://#{@env}/v3/versions?page[number]=1&page[size]=10",
                                    { content_type: :json, Accept: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :password, :environment

        def initialize(token, email, environment)
          @email = email
          @env = environment
          @token = token
        end

        def response
          @response ||= get_list
        end

      end
  end
end
