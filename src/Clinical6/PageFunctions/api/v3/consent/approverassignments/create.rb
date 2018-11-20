require_relative "../../../base_api"

module V3
  module Consent
    module ApproverAssignments
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "consent__approver_assignments",
              "attributes": {},
              "relationships": {
                "approver": {
                  "data": {
                    "id": "#{approver_id}",
                    "type": "consent__approvers"
                  }
                },
                "approver_group": {
                  "data": {
                    "id": "#{group_id}",
                    "type": "consent__approver_groups"
                  }
                }
              }
            }
          }
          JSON
        end

        private def post_create
          response = RestClient.post("https://#{@env}/v3/consent/approver_assignments", payload.to_json,
                                     { content_type: :json, Accept: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :approver_id, :group_id

        def initialize(token, email, environment, approver_id, group_id)
          @email = email
          @env = environment
          @token = token
          @approver_id = approver_id
          @group_id = group_id
        end

        def response
          @response ||= post_create
        end

        def id
          @id ||= JSON.parse(response.body).dig("data", "id")
        end

      end
    end
  end
end
