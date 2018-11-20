require_relative "../../base_api"

module V3
  module VideoConsultationParticipants
    class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "video_consultation_participants",
              "attributes": {},
              "relationships": {
                "video_consultation": {
                  "data": {
                    "id": "#{id}",
                    "type": "video_consultations"
                  }
                },
                "participant": {
                  "data": {
                    "id": "2",
                    "type": "mobile_users"
                  }
                }
              }
            }
          }
          JSON
        end

        private def post_create
          response = RestClient.post("https://#{@env}/v3/video_consultation_participants", payload.to_json,
                                     { content_type: :json, Accept: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id

        def initialize(token, email, environment, id)
          @email = email
          @env = environment
          @token = token
          @id = id
        end

        def response
          @response ||= post_create
        end

        def participant_id
          @participant_id ||= JSON.parse(response.body).dig("data", "id")
        end

    end
  end
end
