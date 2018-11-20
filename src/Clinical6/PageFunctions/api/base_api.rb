require 'json'
require 'rest-client'
#require 'awesome_print'

class BaseAPI

  def self.print_request_response(response_header, response_body, request_inspect, request_payload = '')

    puts "---------------------------"
    puts "Request: #{request_inspect} "
    if (request_payload != '')
      puts "Request_payload: #{request_payload}"
    end

    puts "Response: response_headers: " + response_header
    puts "Response: response_body: " + response_body
  end
end