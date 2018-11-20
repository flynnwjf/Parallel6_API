require_relative "../../../base_api"

module V3
  module Agreement
    module Templates
      class List < BaseAPI

        private def list_session
          response = RestClient.get("https://#{@env}/v3/agreement/templates",
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id

        def initialize(token, email, environment)
          @email = email
          @env = environment
          @token = token
        end

        def response
          @response ||= list_session
        end

        def id
          @id ||= JSON.parse(response).dig('data', 0, 'id')
        end

      end
    end
  end
end
