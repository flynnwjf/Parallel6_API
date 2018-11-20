require_relative "../../base_api"

module V3
  module VideoConsultations
    class Join < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "attributes": {},
              "relationships": {
                "video_consultation": {
                  "data": {
                    "id": "#{video_consultation_id}",
                    "type": "video_consultations"
                  }
                },
                "video_consultation_participant": {
                  "data": {
                    "id": "#{video_consultation_participant_id}",
                    "type": "video_consultation_participants"
                  }
                }
              }
            }
          }
          JSON
        end

        private def post_join
          response = RestClient.post("https://#{@env}/v3/video_consultation_join", payload.to_json,
                                     { content_type: :json, Accept: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :video_consultation_id, :video_consultation_participant_id

        def initialize(token, email, environment, video_consultation_id, video_consultation_participant_id)
          @email = email
          @env = environment
          @token = token
          @video_consultation_id = video_consultation_id
          @video_consultation_participant_id = video_consultation_participant_id
        end

        def response
          @response ||= post_join
        end

    end
  end
end
