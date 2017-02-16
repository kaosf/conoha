require 'json'

class Conoha
  class Config
    attr_reader :username, :password, :tenant_id, :public_key, :authtoken, :accounts

    class Error < StandardError; end

    class Account
      attr_reader :username, :password, :tenant_id, :public_key

      def initialize(h)
        @username   = h['username']
        @password   = h['password']
        @tenant_id  = h['tenant_id']
        @public_key = h['public_key']
      end

      def to_hash
        {
          'username'   => @username,
          'password'   => @password,
          'tenant_id'  => @tenant_id,
          'public_key' => @public_key,
        }
      end
    end

    def load_from_yaml!(yaml_str)
      loaded = YAML.load yaml_str
      raise Error.new unless loaded.is_a? Hash
    end

    def load_from_json!(json_str)
      parsed = JSON.parse json_str
      raise Error.new unless parsed.is_a? Hash
      @username = parsed["username"]
      @password = parsed["password"]
      @tenant_id = parsed["tenant_id"]
      @public_key = parsed["public_key"]
      @authtoken = parsed["authtoken"]
      @accounts = parsed["accounts"]&.map { |e| Account.new e }
    end

    def authtoken=(authtoken)
      @authtoken = authtoken
    end
  end
end
