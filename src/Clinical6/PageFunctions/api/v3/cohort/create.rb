require_relative "../../base_api"

module V3
  module Cohort
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "cohort",
              "attributes": {
                "name": "#{name}",
                "cohort_type": "#{cohort_type}"
              }
            }
          }
          JSON
        end

        private def post_create
          response = RestClient.post("https://#{@env}/v3/cohorts", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :name, :cohort_type

        def initialize(token, email, environment, name, cohort_type)
          @email = email
          @env = environment
          @token = token
          @name = name
          @cohort_type = cohort_type
        end

        def response
          @response ||= post_create
        end

        def cohort_id
          @cohort_id ||= JSON.parse(response.body).dig("data", "id")
        end

      end
  end
end
