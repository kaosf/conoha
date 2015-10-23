require 'net/https'
require 'uri'

# @return [Net::HTTPResponse]
# @params [String] uri_string URI string
# @params [String] authtoken
def https_get(uri_string, authtoken)
  uri = URI.parse uri_string
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  req = Net::HTTP::Get.new(uri.path)
  req['Content-Type'] = 'application/json'
  req['Accept'] = 'application/json'
  req['X-Auth-Token'] = authtoken
  https.request(req)
end

# @return [Net::HTTPResponse]
# @params [String] uri_string URI string
# @params [Hash] payload HTTP request body
def https_post(uri_string, payload)
  uri = URI.parse uri_string
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  req = Net::HTTP::Post.new(uri.request_uri)
  req['Content-Type'] = 'application/json'
  req['Accept'] = 'application/json'
  req.body = payload.to_json
  https.request(req)
end

# @params [Array<String>]
#   The return value of `ip_address_of` method. It is either
#
#       ["111.111.111.111", "1111:1111:1111:1111:1111:1111:1111:1111"]
#
#   or
#
#       ["1111:1111:1111:1111:1111:1111:1111:1111", "111.111.111.111"]
#
# @return [String] IPv4 address (e.g. "111.111.111.111")
def ipv4(ip_address)
  ip_address.select { |e| e =~ /\d+\.\d+\.\d+\.\d+/ }.first
end
