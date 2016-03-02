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
# @params [String|nil] authtoken
#   Authtoken string or `nil`.
#   Can pass `nil` only on authenticating with username and password.
def https_post(uri_string, payload, authtoken)
  uri = URI.parse uri_string
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  req = Net::HTTP::Post.new(uri.request_uri)
  req['Content-Type'] = 'application/json'
  req['Accept'] = 'application/json'
  req['X-Auth-Token'] = authtoken
  req.body = payload.to_json
  https.request(req)
end

# @return [Net::HTTPResponse]
# @params [String] uri_string URI string
# @params [String] authtoken
def https_delete(uri_string, authtoken)
  uri = URI.parse uri_string
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  req = Net::HTTP::Delete.new(uri.request_uri)
  req['Content-Type'] = 'application/json'
  req['Accept'] = 'application/json'
  req['X-Auth-Token'] = authtoken
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

# @return [String] UUID of image
# @params [String] os OS name
# @raise [StandardError] When the OS name isn't be contained.
def image_ref_from_os(os)
  dictionary = {
    'ubuntu'   => '793be3e1-3c33-4ab3-9779-f4098ea90eb5', # Ubuntu 14.04 amd64
    'centos67' => 'cd13a8b9-6b57-467b-932e-eee5edcd8d6c', # CentOS 6.7
    'centos72' => 'e6f59a37-93d2-47cc-91a2-eb35abdfe45b', # CentOS 7.2
    'arch'     => 'f5e5b475-ebec-4973-99c7-bc8add5d16c4', # Arch
  }
  if dictionary.keys.include? os
    dictionary[os]
  else
    raise StandardError.new <<EOS
Select os name from the following list:

#{dictionary.keys.join("\n")}
EOS
  end
end
