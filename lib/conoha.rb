require 'conoha/version'
require 'conoha/util'
require 'json'

class Conoha
  def self.init!
    load_config!
  end

  def self.region
    @@region || 'tyo1'
  end

  def self.authenticate!
    uri = "https://identity.#{region}.conoha.io/v2.0/tokens"
    payload = {
        auth: {
          passwordCredentials: {
            username: @@username,
            password: @@password
          },
          tenantId: @@tenant_id
        }
      }
    res = https_post uri, payload, nil
    if res.code == '401'
      raise StandardError.new 'Authentication failure'
    end
    @@authtoken = JSON.parse(res.body)["access"]["token"]["id"]
    save_config!
  end

  def self.authenticate_user!(user_id)
    uri = "https://identity.#{region}.conoha.io/v2.0/tokens"

    credential = @@accounts[user_id]
    if credential.nil?
      raise StandardError.new "User \"#{user_id}\" doesn't exist."
    end

    payload = {
        auth: {
          passwordCredentials: {
            username: credential['username'],
            password: credential['password']
          },
          tenantId: credential['tenant_id']
        }
      }
    res = https_post uri, payload, nil
    if res.code == '401'
      raise StandardError.new 'Authentication failure'
    end

    @@username = credential['username']
    @@password = credential['password']
    @@tenant_id = credential['tenant_id']
    @@public_key = credential['public_key']
    @@authtoken = JSON.parse(res.body)["access"]["token"]["id"]
    save_config!
  end

  def self.username
    @@username
  end

  # @return [Fixnum|String]
  #   Fixnum:
  #     1: conoha-config.json doesn't have "accounts" key
  #     2: "accounts" doesn't have deafult "username"
  #   String: "id" of "accounts".
  def self.whoami
    if @@accounts.nil?
      1
    else
      if result = @@accounts.find { |k, v| v['username'] == @@username }
        result.first
      else
        2
      end
    end
  end

  def self.servers
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers"
    res = https_get uri, authtoken
    JSON.parse(res.body)["servers"]
  end

  def self.vps_list
    servers.map { |e| e["id"] }
  end

  # @raise [StandardError]
  #   when "os" doesn't exist in image_tag_dictionary
  #   when "image_tag" doesn't exist in images
  def self.create(os, ram)
    image_ref = image_ref_from_image_tag(image_tag_dictionary(os))
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers"
    payload = {
      server: {
        adminPass: randstr,
        imageRef: image_ref,
        flavorRef: flavor_ref(ram),
        key_name: public_key,
        security_groups: [{name: 'default'}, {name: 'gncs-ipv4-all'}],
      }
    }
    res = https_post uri, payload, authtoken
    JSON.parse(res.body)["server"]["id"]
  end

  def self.rebuild(server_id, os)
    image_ref = image_ref_from_image_tag(image_tag_dictionary(os))
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers/#{server_id}/action"
    payload = {
      rebuild: {
        imageRef: image_ref,
        adminPass: randstr,
        key_name: public_key
      }
    }
    res = https_post uri, payload, authtoken
    res.code == '202' ? 'OK' : 'Error'
  end

  def self.delete(server_id)
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers/#{server_id}"
    res = https_delete uri, authtoken
    res.code == '204' ? 'OK' : 'Error'
  end

  def self.ip_address_of(server_id)
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers/#{server_id}"
    res = https_get uri, authtoken
    # NOTE: values[1] is needed if eth1 exists.
    JSON.parse(res.body)["server"]["addresses"].values[0].map{ |e| e["addr"] }
  end

  def self.status_of(server_id)
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers/#{server_id}"
    res = https_get uri, authtoken
    JSON.parse(res.body)["server"]["status"]
  end

  # @param [String] action "os-start", "os-stop" or "reboot"
  # @param [Hash|nil] action_value (default: nil)
  def self.server_action(server_id, action, action_value = nil)
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers/#{server_id}/action"
    res = https_post uri, {action => action_value}, authtoken
    res.code == '202' ? 'OK' : 'Error'
  end

  def self.boot(server_id)
    server_action server_id, "os-start"
  end

  def self.shutdown(server_id)
    server_action server_id, "os-stop"
  end

  # @param [String] server_id
  # @param [String] type "SOFT" or "HARD" (ref. https://www.conoha.jp/docs/compute-reboot_vm.html)
  def self.reboot(server_id, type = "SOFT")
    server_action(server_id, "reboot", { "type" => type })
  end

  def self.images
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/images"
    res = https_get uri, authtoken
    JSON.parse(res.body)["images"].map { |e| [e["name"], e["id"]] }
  end

  def self.create_image(server_id, name)
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers/#{server_id}/action"
    res = https_post uri, {"createImage" => {"name" => name}}, authtoken
    res.code == '202' ? 'OK' : 'Error'
  end

  def self.delete_image(image_ref)
    uri = "https://image-service.#{region}.conoha.io/v2/images/#{image_ref}"
    res = https_delete uri, authtoken
    res.code == '204' ? 'OK' : 'Error'
  end

  def self.create_from_image(image_ref, ram)
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers"
    payload = {
      server: {
        adminPass: randstr,
        imageRef: image_ref,
        flavorRef: flavor_ref(ram),
        key_name: public_key,
        security_groups: [{name: 'default'}, {name: 'gncs-ipv4-all'}],
      }
    }
    res = https_post uri, payload, authtoken
    JSON.parse(res.body)["server"]["id"]
  end

  def self.name_tag(server_id)
    uri = "https://compute.#{region}.conoha.io/v2/#{tenant_id}/servers/#{server_id}/metadata"
    res = https_get uri, authtoken
    JSON.parse(res.body)["metadata"]["instance_name_tag"]
  end

  private

  @@config_loaded = false

  def self.config_file_path
    ENV['HOME'] + '/.conoha-config.json'
  end

  def self.config_file_string
    unless File.exist? config_file_path
      STDERR.print <<EOS
Create "~/.conoha-config.json".
For example:

cat <<EOF > ~/.conoha-config.json
{
  "username": "gncu123456789",
  "password": "your-password",
  "tenant_id": "0123456789abcdef",
  "public_key": "your-registered-public-key-name"
}
EOF
chmod 600 ~/.conoha-config.json # For security
EOS
      exit 1
    end
    File.open(config_file_path).read
  end

  def self.load_config!
    unless @@config_loaded
      config = JSON.parse config_file_string
      @@username = config["username"]
      @@password = config["password"]
      @@region = config["region"]
      @@tenant_id = config["tenant_id"]
      @@public_key = config["public_key"]
      @@authtoken = config["authtoken"]
      @@accounts = config["accounts"]
      @@config_loaded = true
    end
  end

  def self.save_config!
    s = JSON.generate({
      username: @@username,
      password: @@password,
      region: @@region,
      tenant_id: @@tenant_id,
      public_key: @@public_key,
      authtoken: @@authtoken,
      accounts: @@accounts
    })
    File.open(config_file_path, 'w') do |f|
      f.write s
    end
  end

  def self.tenant_id
    @@tenant_id
  end

  def self.authtoken
    @@authtoken
  end

  def self.public_key
    @@public_key
  end

  # @return [String] server ID (UUID)
  # @param [String] image_tag e.g. "vmi-centos-7-amd64"
  # @raise [StandardError] when image_tag doesn't exist in images
  def self.image_ref_from_image_tag(image_tag)
    if image = images.find { |e| e[0] == image_tag }
      image[1]
    else
      raise StandardError.new "Tag \"#{tag}\" doesn't exist in image list."
    end
  end

  def self.flavor_ref(ram)
    dictionary = {
      'g-1gb'  => '7eea7469-0d85-4f82-8050-6ae742394681',
      'g-2gb'  => '294639c7-72ba-43a5-8ff2-513c8995b869',
      'g-4gb'  => '62e8fb4b-6a26-46cd-be13-e5bbf5614d15',
      'g-8gb'  => '965affd4-d9e8-4ffb-b9a9-624d63e2d83f',
      'g-16gb' => '3aa001cd-95b6-46c9-a91e-e62d6f7f06a3',
      'g-32gb' => 'a20905c6-3733-46c4-81cc-458c7dca1bae',
      'g-64gb' => 'c2a97b05-1b4b-4038-bbcb-343201659279',
    }
    if dictionary.keys.include? ram
      dictionary[ram]
    else
STDERR.print <<EOS
select ram flavor name from the following list:

#{dictionary.keys.map { |e| "  #{e}" }.join("\n")}
EOS
      exit 1
    end
  end

  def self.randstr
    (1..60).map{['0'..'9','a'..'z','A'..'Z'].map(&:to_a).flatten.sample}.join
  end
end
