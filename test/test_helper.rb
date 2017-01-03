require 'simplecov'
require 'coveralls'
require 'test/unit'
require 'test/unit/rr'

Coveralls.wear!
if ENV['CI'] != 'true'
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  SimpleCov.start
end

# require order ref.
#   http://qiita.com/bsdmad/items/ab8b7d92d965df8bb2d8
# ENV['CI'] != 'true" ref.
#   http://docs.travis-ci.com/user/environment-variables/#Default-Environment-Variables
