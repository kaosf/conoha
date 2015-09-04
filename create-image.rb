require './conoha'

Conoha.init!

exit 1 if ARGV.size != 2
server_id = ARGV[0]
unless server_id.length == '01234567-89ab-cdef-0123-456789abcdef'.length
  server_id = Conoha.vps_list[server_id.to_i]
end
name = ARGV[1]

puts Conoha.create_image server_id, name
