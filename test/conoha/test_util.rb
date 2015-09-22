require 'test_helper'
require 'conoha/util'

class TestConohaUtil < Test::Unit::TestCase
  data(
    "IPv4 first" => ["111.111.111.111", ["111.111.111.111", "1111:1111:1111:1111:1111:1111:1111:1111"]],
    "IPv4 last"  => ["111.111.111.111", ["1111:1111:1111:1111:1111:1111:1111:1111", "111.111.111.111"]],
  )
  test ".ipv4" do |(expected, input)|
    actual = ipv4 input
    assert_equal expected, actual
  end
end
