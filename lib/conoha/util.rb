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
