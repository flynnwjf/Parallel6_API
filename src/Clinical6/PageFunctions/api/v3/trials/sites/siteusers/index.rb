require_relative "../../../../base_api"

module V3
  module Trials
    module Sites
      module SiteUsers
        class Index < BaseAPI

          private def get_index
            response = RestClient.get("https://#{@env}/v3/trials/sites/#{@id}/site_users",
                                      { content_type: :json, accept: :json,
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
            @response ||= get_index
          end

          def user_id
            @user_id ||= JSON.parse(response).dig("data", 0, "attributes", "user_id")
          end

        end
      end
    end
  end
end
