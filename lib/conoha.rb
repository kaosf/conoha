require "conoha/version"

require 'net/https'
require 'uri'
require 'json'

class Conoha
  def self.init!
    load_config!
  end

  def self.authenticate!
    #uri = URI.parse 'https://identity.tyo1.conoha.io/v2.0/tokens'
    #https = Net::HTTP.new(uri.host, uri.port)
    #https.use_ssl = true
    #req = Net::HTTP::Post.new(uri.request_uri)
    #req['Content-Type'] = 'application/json'
    #payload = {
    #  auth: {
    #    passwordCredentials: {
    #      username: $USERNAME,
    #      password: $PASSWORD
    #    },
    #    tenant_id: $TENANT_ID
    #  }
    #}.to_json
    #req.body = payload
    #res = https.request(req)

    req_json = JSON.generate({
      auth: {
        passwordCredentials: {
          username: @@username,
          password: @@password
        },
        tenantId: @@tenant_id
      }
    })
    command = <<EOS
curl -X POST -H "Accept: application/json" \
  -d '#{req_json}' \
  https://identity.tyo1.conoha.io/v2.0/tokens 2> /dev/null
EOS
    result = `#{command}`

    #token = JSON.parse(res.body)["access"]["token"]["id"]
    token = JSON.parse(result)["access"]["token"]["id"]

    @@authtoken = token
    save_config!
  end

  def self.servers
    uri = URI.parse "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Get.new(uri.path)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    res = https.request(req)
    JSON.parse(res.body)["servers"]
  end

  def self.vps_list
    servers.map { |e| e["id"] }
  end

  def self.create(os, ram)
    uri = URI.parse "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    payload = {
      server: {
        adminPass: randstr,
        imageRef: image_ref_from_os(os),
        flavorRef: flavor_ref(ram),
        key_name: public_key,
        security_groups: [
          {name: 'default'},
          {name: 'gncs-ipv4-all'}
        ]
      }
    }.to_json
    req.body = payload
    res = https.request(req)
    JSON.parse(res.body)["server"]["id"]
  end

  def self.delete(server_id)
    uri = URI.parse "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Delete.new(uri.request_uri)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    res = https.request(req)
    res.code == '204' ? 'OK' : 'Error'
  end

  def self.ip_address_of(server_id)
    uri = URI.parse "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Get.new(uri.path)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    res = https.request(req)
    JSON.parse(res.body)["server"]["addresses"].values[0].map{ |e| e["addr"] }
  end

  def self.boot(server_id)
    uri = URI.parse "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}/action"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    req.body = {"os-start": nil}.to_json
    res = https.request(req)
    res.code == '202' ? 'OK' : 'Error'
  end

  def self.shutdown(server_id)
    uri = URI.parse "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}/action"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    req.body = {"os-stop": nil}.to_json
    res = https.request(req)
    res.code == '202' ? 'OK' : 'Error'
  end

  def self.images
    uri = URI.parse "https://compute.tyo1.conoha.io/v2/#{tenant_id}/images"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Get.new(uri.path)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    res = https.request(req)
    JSON.parse(res.body)["images"].map { |e| [e["name"], e["id"]] }
  end

  def self.create_image(server_id, name)
    uri = URI.parse "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}/action"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    req.body = {"createImage": {"name": name}}.to_json
    res = https.request(req)
    res.code == '202' ? 'OK' : 'Error'
  end

  def self.delete_image(image_ref)
    uri = URI.parse "https://image-service.tyo1.conoha.io/v2/images/#{image_ref}"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Delete.new(uri.request_uri)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    res = https.request(req)
    res.code == '204' ? 'OK' : 'Error'
  end

  def self.create_from_image(image_ref, ram)
    uri = URI.parse "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers"
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'
    req['X-Auth-Token'] = authtoken
    payload = {
      server: {
        adminPass: randstr,
        imageRef: image_ref,
        flavorRef: flavor_ref(ram),
        key_name: public_key,
        security_groups: [
          {name: 'default'},
          {name: 'gncs-ipv4-all'}
        ]
      }
    }.to_json
    req.body = payload
    res = https.request(req)
    JSON.parse(res.body)["server"]["id"]
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
      @@tenant_id = config["tenant_id"]
      @@public_key = config["public_key"]
      @@authtoken = config["authtoken"]
      @@config_loaded = true
    end
  end

  def self.save_config!
    s = JSON.generate({
      username: @@username,
      password: @@password,
      tenant_id: @@tenant_id,
      public_key: @@public_key,
      authtoken: @@authtoken,
    })
    File.open(config_file_path, 'w').write s
  end

  def self.tenant_id
    @@tenant_id
  end

  def self.authtoken
    # @@authtoken || (authenticate!; @@authtoken)
    @@authtoken
  end

  def self.public_key
    @@public_key
  end

  def self.image_ref_from_os(os)
    dictionary = {
      'ubuntu'   => '2b03327f-d453-4c7d-91c9-8b9924b6ea88', # Ubuntu 14.04 amd64
      'centos66' => 'fa67ec7b-b9b4-4633-9012-fc5a6303aba7', # CentOS 6.6 (owncloud 8) (default)
      'centos67' => '91944101-df61-4c41-b7c5-76cebfc48318', # CentOS 6.7
      'centos71' => 'edc9457e-e4a8-4974-8217-c254d215b460', # CentOS 7.1
      'arch'     => 'b5c921c5-2f71-4cfe-9c5a-5783ce0be87b', # Arch
    }
    if dictionary.keys.include? os
      dictionary[os]
    else
STDERR.print <<EOS
select os name from the following list:

#{dictionary.keys.map { |e| "  #{e}" }.join("\n")}
EOS
      exit 1
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
    ['0'..'9', 'a'..'z', 'A'..'Z'].map(&:to_a).flatten.sample(60).join
  end
end
