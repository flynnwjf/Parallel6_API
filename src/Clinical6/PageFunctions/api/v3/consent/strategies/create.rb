require_relative "../../../base_api"

module V3
  module Consent
    module Strategies
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
          "data": {
              "type": "conset__strategies",
              "attributes": {
                "name": "#{name}",
                "strategy_type": "#{type}"
              },
              "relationships": {
                "cohort": {
                  "data": {
                    "id": #{id},
                    "type": "cohorts"
                  }
                }
              }
            }
           }
          JSON
        end

        private def post_create
          response = RestClient.post("https://#{@env}/v3/consent/strategies", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id, :name, :type

        def initialize(token, email, environment, name, type, id)
          @email = email
          @env = environment
          @token = token
          @name = name
          @type = type
          @id = id
        end

        def response
          @response ||= post_create
        end

        def consent_strategies_id
          @consent_strategies_id ||= JSON.parse(response.body).dig("data", "id")
        end

      end
    end
  end
end
