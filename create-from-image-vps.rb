require './conoha'

Conoha.init!

exit 1 if ARGV.size != 2
image_ref = ARGV[0]
ram = ARGV[1]

puts Conoha.create_from_image image_ref, ram
