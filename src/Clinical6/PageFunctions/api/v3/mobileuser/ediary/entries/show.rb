require_relative "../../../../base_api"

module V3
  module MobileUser
    module Ediary
      module Entries
        class Show < BaseAPI

          private def get_show
            response = RestClient.get("https://#{@env}/v3/mobile_users/#{id}/ediary/entries",
                                      { content_type: :json, Accept: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email }
            ) { |response, request, result| response }
            BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
            return response
          end

          private def get_show_filter
            response = RestClient.get("https://#{@env}/v3/mobile_users/#{id}/ediary/entries?filters[date]=2018-06-11",
                                      { content_type: :json, Accept: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email }
            ) { |response, request, result| response }
            BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
            return response
          end

          attr_reader :email, :token, :env, :id

          def initialize(token, email, environment, id)
            @email = email
            @env = environment
            @token = token
            @id = id
          end

          def response
            @response ||= get_show
          end

          def response_filter
            @response ||= get_show_filter
          end

        end
      end
    end
  end
end
