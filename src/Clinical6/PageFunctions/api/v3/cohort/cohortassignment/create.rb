require_relative "../../../base_api"

module V3
  module Cohort
    module CohortAssignment
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "cohort_assignment",
              "relationships": {
                "cohort": {
                  "data": {
                  "type": "cohort",
                  "id": #{@id}
                  }
                },
                "user": {
                  "data": {
                  "type": "#{@type}",
                  "id": 1
                  }
                }
              }
            }
          }
          JSON
        end

        private def post_create
          response = RestClient.post("https://#{@env}/v3/cohort_assignments", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id, :type

        def initialize(token, email, environment, id, type)
          @email = email
          @env = environment
          @token = token
          @id = id
          @type = type
        end

        def response
          @response ||= post_create
        end

        def cohort_assignment_id
          @cohort_assignment_id ||= JSON.parse(response.body).dig("data", "id")
        end

      end
    end
  end
end
