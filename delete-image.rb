require './conoha'

Conoha.init!

exit 1 if ARGV.size != 1
image_ref = ARGV.first

puts Conoha.delete_image image_ref
