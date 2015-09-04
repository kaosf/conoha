require './conoha'
require 'pp'

Conoha.init!

exit 1 if ARGV.size != 2
os = ARGV[0]
ram = ARGV[1]

pp Conoha.create os, ram
