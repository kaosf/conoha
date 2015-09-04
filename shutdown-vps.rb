require './conoha'

Conoha.init!

exit 1 if ARGV.size != 1
server_id = ARGV.first
unless server_id.length == '01234567-89ab-cdef-0123-456789abcdef'.length
  server_id = Conoha.vps_list[server_id.to_i]
end

puts Conoha.shutdown server_id
