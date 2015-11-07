require 'test_helper'
require 'conoha/config'

class TestConohaConfig < Test::Unit::TestCase
  setup do
    @config = Conoha::Config.new
  end

  test '#load_from_yaml!' do
    #pending
  end

  sub_test_case '#load_from_json!' do
    sub_test_case 'raise error when invalid json' do
      test 'empty string' do
        assert_raise(JSON::ParserError) { @config.load_from_json! '' }
      end

      test '[]' do
        assert_raise(Conoha::Config::Error) { @config.load_from_json! '[]' }
      end
    end

    test 'no authtoken' do
      json = <<-EOS
{
  "username": "a",
  "password": "b",
  "tenant_id": "c",
  "public_key": "d"
}
EOS
      @config.load_from_json! json
      assert { @config.username   == "a" }
      assert { @config.password   == "b" }
      assert { @config.tenant_id  == "c" }
      assert { @config.public_key == "d" }
      assert { @config.authtoken.nil? }
    end


    test 'with authtoken' do
      json = <<-EOS
{
  "username": "a",
  "password": "b",
  "tenant_id": "c",
  "public_key": "d",
  "authtoken": "e"
}
EOS
      @config.load_from_json! json
      assert { @config.username   == "a" }
      assert { @config.password   == "b" }
      assert { @config.tenant_id  == "c" }
      assert { @config.public_key == "d" }
      assert { @config.authtoken  == "e" }
    end
  end

  test '#authtoken=' do
    assert { @config.authtoken.nil? }
    @config.authtoken = 'a'
    assert { @config.authtoken == 'a' }
  end
end
