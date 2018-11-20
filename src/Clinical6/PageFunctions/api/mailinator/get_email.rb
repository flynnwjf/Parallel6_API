require_relative "../../../PageFunctions/api/base_api"

module MAILINATOR
  class GetEmail < BaseAPI

    private def get_email

      response = RestClient.get("https://api.mailinator.com/api/email?id=#{email_id}&token=20cf21802f1a4fe18eebcb2e8efdc901&private_domain=true",
                                { content_type: :json }) { |response, request, result| response }
      BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
      return response
    end

    attr_reader :email_id

    def initialize(email_id_from_mailinator)
      @email_id = email_id_from_mailinator
    end

    def response
      @response ||= get_email
    end

    def from_field
      @from_field ||= JSON.parse(response).dig('data', 'from')
    end
    def subject
      @subject ||= JSON.parse(response).dig('data', 'subject')
    end
    def email_body
      @email_body ||= JSON.parse(response).dig('data', 'parts', 0, 'body')
    end


  end
end

