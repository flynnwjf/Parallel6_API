require_relative "../../base_api"

module V3
  module FilterGroups
     class Create < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                 "operator": "or"
                     },
                    "relationships": {
                       "cohort": {
                           "data": {
                               "type": "cohort",
                                "id": "#{@cohort_id}"
                           }
                        }
                    }
                }   
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/filter_groups",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :token, :type, :cohort_id

        def initialize(token, email, environment, type, cohort_id)
          @email = email
          @env = environment
          @token = token
          @type = type
          @cohort_id = cohort_id
        end

        def response
          @response ||= create_session
        end

        def id
          @id ||= JSON.parse(response).dig('data', 'id')
        end

      end
  end
end
