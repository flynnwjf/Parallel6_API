require_relative "../../../base_api"

module V3
  module DataCollection
    module FlowProcessValues
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
           {
            "data": {
              "type": "data_collection__flow_process_values",
              "attributes": {
                  "22": "#{text}",
                  "submitted_at":"#{text}"
              },
              "relationships": {
                "flow_process": {
                  "data": {
                    "type": "data_collection__flow_processes",
                    "id": "#{flow_id}"
                  }
                },
                "owner": {
                  "data": {
                    "type": "mobile_users",
                    "id": "#{mobile_id}"
                   }
                },
                "captured_value_group": {
                  "data": {
                    "type": "data_collection__captured_value_groups",
                    "id": #{group_id}
                  }
                }
              }
            }
          }
          JSON
        end

        private def post_create
          response = RestClient.post("https://#{@env}/v3/data_collection/flow_process_values", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        private def post_create_by_mobile
          response = RestClient.post("https://#{@env}/v3/data_collection/flow_process_values", payload.to_json,
                                     { content_type: :json,
                                       'Authorization' => "Token token=#{@token}" }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :flow_id, :mobile_id, :group_id, :text

        def initialize(token, email, environment, flow_id, mobile_id, group_id, text)
          @email = email
          @env = environment
          @token = token
          @flow_id = flow_id
          @mobile_id = mobile_id
          @group_id = group_id
          @text = text
        end

        def response
          @response ||= post_create
        end

        def response_mobile
          @response ||= post_create_by_mobile
        end

      end
    end
  end
end
