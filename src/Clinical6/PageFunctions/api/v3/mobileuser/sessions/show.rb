require_relative "../../../base_api"

module V3
  module MobileUser
    module Session
      class Show < BaseAPI

        private def get_show
          response = RestClient.get("https://#{@env}/v3/mobile_users/sessions/show",
                                     { content_type: :json, Accept: :json,
                                       'Authorization' => "Token token=#{@token}" }) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :environment, :token

        def initialize(environment, token)
          @env = environment
          @token = token
        end

        def response
          @response ||= get_show
        end

      end
    end
  end
end
