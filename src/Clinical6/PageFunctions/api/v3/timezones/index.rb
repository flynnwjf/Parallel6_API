require_relative "../../base_api"

module V3
  module Timezones
    class Index < BaseAPI


      private def update_user_attr
        response = RestClient.get("https://#{@env}/v3/timezones?sort=offset",
                                  { content_type: :json,
                                    'X-User-Token' => @token,
                                    'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
        return response

      end


      def initialize(environment)
        @env = environment
      end


      def response
        @response ||= update_user_attr
      end

    end
  end
end
