require 'test_helper'
require 'conoha/util'

class TestConohaUtil < Test::Unit::TestCase
  sub_test_case 'HTTPS request utilities' do
    setup do
      @uri = 'https://example.com/a/b/c'
      @payload = {}
      @auth_token = '0123456789abcdef'
    end

    test "https_get" do
      any_instance_of(Net::HTTP) { |https| stub(https).request }
      assert_nothing_raised { https_get @uri, @auth_token }
    end

    test "https_post" do
      any_instance_of(Net::HTTP) { |https| stub(https).request }
      assert_nothing_raised { https_post @uri, @payload, @auth_token }
    end

    test "https_delete" do
      any_instance_of(Net::HTTP) { |https| stub(https).request }
      assert_nothing_raised { https_delete @uri, @auth_token }
    end
  end

  data(
    "IPv4 first" => ["111.111.111.111", ["111.111.111.111", "1111:1111:1111:1111:1111:1111:1111:1111"]],
    "IPv4 last"  => ["111.111.111.111", ["1111:1111:1111:1111:1111:1111:1111:1111", "111.111.111.111"]],
  )
  test ".ipv4" do |(expected, input)|
    actual = ipv4 input
    assert_equal expected, actual
  end

  sub_test_case 'image_tag_dictionary' do
    test 'normal' do
      assert_equal 'vmi-ubuntu-16.04-amd64', image_tag_dictionary('ubuntu')
    end

    test 'no index' do
      assert_raise(StandardError) { image_tag_dictionary 'invalid-os' }
    end
  end
end
