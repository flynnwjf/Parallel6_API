require_relative "../../../base_api"

module V3
  module DataCollection
    module CapturedValueGroups
      class Index < BaseAPI

        private def get_index
          response = RestClient.get("https://#{@env}/v3/data_collection/captured_value_groups",
                                       { content_type: :json,
                                         'X-User-Token' => @token,
                                         'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        private def get_index_by_mobile
          response = RestClient.get("https://#{@env}/v3/data_collection/captured_value_groups",
                                    { content_type: :json,
                                      'Authorization' => "Token token=#{@token}" }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :token, :env

        def initialize(token, email, environment)
          @email = email
          @env = environment
          @token = token
        end

        def response
          @response ||= get_index
        end

        def response_mobile
          @response ||= get_index_by_mobile
        end

        def count
          @count ||= JSON.parse(response.body)["data"].size
        end

        def id
          i = 0
          while(!JSON.parse(response.body).dig('data', i, 'attributes', 'owner_type').eql?("MobileUser"))
            i = i+1
          end
          @group_id ||= JSON.parse(response.body).dig('data', i, 'id')
          @flow_process_id ||= JSON.parse(response.body).dig('data', i, 'relationships', 'flow_process', 'data', 'id')
          @mobile_user_id ||= JSON.parse(response.body).dig('data', i, 'relationships', 'owner', 'data', 'id')
          {:group => @group_id, :flow_process => @flow_process_id, :mobile_user => @mobile_user_id}
        end

        def id_by_mobile(mobile_user)
          for i in 0..count-1
            if (JSON.parse(response.body).dig('data', i, 'relationships', 'owner', 'data', 'id') == mobile_user)
              @group_id ||= JSON.parse(response.body).dig('data', i, 'id')
              @flow_process_id ||= JSON.parse(response.body).dig('data', i, 'relationships', 'flow_process', 'data', 'id')
            end
          end
          {:group => @group_id, :flow_process => @flow_process_id}
        end

      end
    end
  end
end
