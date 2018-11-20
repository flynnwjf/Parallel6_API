require_relative "../../../../base_api"

module V3
  module MobileUser
    module Consent
      module Consent
        class Delete < BaseAPI

          private def delete
            response = RestClient.delete("https://#{@env}/v3/mobile_users/#{@id}/consent/consent",
                                        { content_type: :json,
                                          'X-User-Token' => @token,
                                          'X-User-Username' => @email }
            ) { |response, request, result| response }
            BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
            return response
          end

          attr_reader :email, :token, :environment, :id

          def initialize(token, email, environment, id)
            @email = email
            @env = environment
            @token = token
            @id = id
          end

          def response
            @response ||= delete
          end

        end
      end
    end
  end
end
