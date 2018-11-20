require_relative "../../../base_api"

module V3
  module Analytics
    module Metrics
      class Show < BaseAPI

        private def get_show
          response = RestClient.get("https://#{@env}/v3/analytics/metrics/#{name}",
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :name

        def initialize(token, email, environment, name)
          @email = email
          @env = environment
          @token = token
          @name = name
        end

        def response
          @response ||= get_show
        end

      end
    end
  end
end
