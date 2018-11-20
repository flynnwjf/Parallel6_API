require_relative "../../base_api"

module V3
  module VideoConsultations
    class Delete < BaseAPI

        private def delete_destory
          response = RestClient.delete("https://#{@env}/v3/video_consultations/#{@id}",
                                     { content_type: :json, Accept: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
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
          @response ||= delete_destory
        end

    end
  end
end
