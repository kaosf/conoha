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

# @return [String] Image name tag
# @params [String] os OS name
# @raise [StandardError] When the OS name isn't included in the dictionary.
def image_tag_dictionary(os)
  dictionary = {
    'ubuntu'   => 'vmi-ubuntu-16.04-amd64-unified', # Ubuntu 16.04 amd64
    'ubuntu16' => 'vmi-ubuntu-16.04-amd64-unified', # Ubuntu 16.04 amd64
    'ubuntu14' => 'vmi-ubuntu-14.04-amd64-unified', # Ubuntu 14.04 amd64
    'debian'   => 'vmi-debian-8.7-amd64-unified', # Debian 8 amd64
    'fedora'   => 'vmi-fedora-25-amd64', # Fedora 25 amd64
    'fedora25' => 'vmi-fedora-25-amd64', # Fedora 25 amd64
    'centos'   => 'vmi-centos-7.3-amd64', # CentOS 7.3
    'centos73' => 'vmi-centos-7.3-amd64', # CentOS 7.3
    'centos72' => 'vmi-centos-7.2-amd64', # CentOS 7.2
    'centos71' => 'vmi-centos-7.1-amd64', # CentOS 7.1
    'centos68' => 'vmi-centos-6.8-amd64', # CentOS 6.8
    'centos67' => 'vmi-centos-6.7-amd64', # CentOS 6.7
    'centos66' => 'vmi-centos-6.6-amd64', # CentOS 6.6
    'arch'     => 'vmi-arch-amd64', # Arch
    'opensuse' => 'vmi-opensuse-42.2-amd64-unified', # openSUSE
    'openbsd'  => 'vmi-openbsd-6.0-amd64', # OpenBSD
    'netbsd'   => 'vmi-netbsd-7.0-amd64', # NetBSD
    'freebsd'  => 'vmi-freebsd-10.3-x86_64', # FreeBSD
    'docker'   => 'vmi-docker-17.06-ubuntu-16.04-unified', # Docker on Ubuntu 16.04

    # 20GB storage for 512MB RAM
    'ubuntu-20gb'   => 'vmi-ubuntu-16.04-amd64-unified-20gb',
    'ubuntu16-20gb' => 'vmi-ubuntu-16.04-amd64-unified-20gb',
    'ubuntu14-20gb' => 'vmi-ubuntu-14.04-amd64-unified-20gb',
    'debian-20gb'   => 'vmi-debian-8.7-amd64-unified-20gb',
    'fedora-20gb'   => 'vmi-fedora-25-amd64-20gb',
    'fedora25-20gb' => 'vmi-fedora-25-amd64-20gb',
    'centos-20gb'   => 'vmi-centos-7.3-amd64-20gb',
    'centos73-20gb' => 'vmi-centos-7.3-amd64-20gb',
    'centos72-20gb' => 'vmi-centos-7.2-amd64-20gb',
    'centos71-20gb' => 'vmi-centos-7.1-amd64-20gb',
    'centos68-20gb' => 'vmi-centos-6.8-amd64-20gb',
    'centos67-20gb' => 'vmi-centos-6.7-amd64-20gb',
    'centos66-20gb' => 'vmi-centos-6.6-amd64-20gb',
    'arch-20gb'     => 'vmi-arch-amd64-20gb',
    'opensuse-20gb' => 'vmi-opensuse-42.2-amd64-unified-20gb',
    'openbsd-20gb'  => 'vmi-openbsd-6.0-amd64-20gb',
    'netbsd-20gb'   => 'vmi-netbsd-7.0-amd64-20gb',
    'freebsd-20gb'  => 'vmi-freebsd-10.3-amd64-20gb',
    'docker-20gb'   => 'vmi-docker-17.06-ubuntu-16.04-unified-20gb',
  }

  if dictionary.keys.include? os
    dictionary[os]
  else
    raise StandardError.new <<EOS
"#{os}" doesn't exist.
Select os name from the following list:

#{dictionary.keys.join("\n")}
EOS
  end
end
