require_relative "../../../../base_api"

module V3
  module Trials
    module Sites
      module SiteUsers
        class Show < BaseAPI

          private def get_show
            response = RestClient.get("https://#{@env}/v3/trials/sites/#{site_id}/site_users/#{user_id}",
                                      { content_type: :json, accept: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email }
            ) { |response, request, result| response }
            BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
            return response
          end

          attr_reader :email, :password, :environment, :site_id, :user_id

          def initialize(token, email, environment, site_id, user_id)
            @email = email
            @env = environment
            @token = token
            @site_id = site_id
            @user_id = user_id
          end

          def response
            @response ||= get_show
          end

        end
      end
    end
  end
end
