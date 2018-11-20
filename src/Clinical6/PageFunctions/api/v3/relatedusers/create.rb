require_relative "../../base_api"

module V3
  module RelatedUsers
    class Create < BaseAPI

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {  
           "data":{  
              "type":"related_users",
              "attributes":{  
        
              },
              "relationships":{  
                 "follower_user":{  
                    "data":{  
                       "type":"mobile_users",
                       "id": #{follower_id}
                    }
                 },
                 "followed_user":{  
                    "data":{  
                       "type":"mobile_users",
                       "id": #{followed_id}
                    }
                 }
              }
           }
        }
        JSON
      end

      private def post_create
        response = RestClient.post("https://#{@env}/v3/related_users", payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :token, :follower_id, :followed_id

      def initialize(token, email, environment, follower_id, followed_id)
        @email = email
        @env = environment
        @token = token
        @follower_id = follower_id
        @followed_id = followed_id
      end

      def response
        @response ||= post_create
      end

      def id
        @id ||= JSON.parse(response).dig('data', 'id')
      end

    end
  end
end
