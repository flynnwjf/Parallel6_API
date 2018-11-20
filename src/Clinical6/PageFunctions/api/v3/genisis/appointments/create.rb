require_relative "../../../base_api"

module V3
  module Genisis
    module Appointments
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
          "data": {
              "type": "#{type}",
              "attributes": {
                 "genisis_id": "#{genisis_id}",
                 "appointment_status": "Scheduled",
                 "cancellation_reason": null,
                 "appointment_source": "reef",
                 "site_id": 1,
                 "study_id": 1,
                 "start_time": "#{start_time}",
                 "end_time": "#{end_time}",
                 "cancellation_comment": "this is a test"
               },
               "relationships": {
                  "mobile_user": {
                     "data": {
                         "id": "#{mobile_user_id}",
                         "type": "mobile_users"
                      }
                  }
               }
            }
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/genisis/appointments", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :token, :env, :type, :genisis_id, :mobile_user_id, :start_time, :end_time

        def initialize(token, email, environment, type, genisis_id, mobile_user_id, start_time, end_time)
          @email = email
          @env = environment
          @token = token
          @type = type
          @genisis_id = genisis_id
          @mobile_user_id = mobile_user_id
          @start_time = start_time
          @end_time = end_time
        end

        def response
          @response ||= create_session
        end

        def id
          @id ||= JSON.parse(response.body).dig("AppointmentId")
        end

      end
    end
  end
end
