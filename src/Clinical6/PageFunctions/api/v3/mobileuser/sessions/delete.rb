require_relative "../../../base_api"

module V3
  module MobileUser
    module Session
      class Delete < BaseAPI

        private def delete_session
          response = RestClient.delete("https://#{@env}/v3/mobile_users/sessions",
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
          @response ||= delete_session
        end

      end
    end
  end
end
