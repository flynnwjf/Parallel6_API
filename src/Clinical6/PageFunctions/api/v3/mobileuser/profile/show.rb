require_relative "../../../base_api"

module V3
  module MobileUser
    module Profile
      class Show < BaseAPI

        attr_reader :token, :environment, :id, :email

        private def get_show
          puts @token
          puts @email
          if (email == "")
            response = RestClient.get("https://#{@env}/v3/mobile_users/#{@id}/profile",
                                      { content_type: :json, Accept: :json,
                                        'Authorization' => "Token token=#{@token}"}
            ) { |response, request, result| response }
          else
            response = RestClient.get("https://#{@env}/v3/mobile_users/#{@id}/profile",
                                      { content_type: :json, Accept: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email
                                      }
            ) { |response, request, result| response }
          end
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        def initialize(id, token, email, environment)
          @token = token
          @env = environment
          @id = id
          @email = email
        end

        def response
          @response ||= get_show
        end

      end
    end
  end
end
