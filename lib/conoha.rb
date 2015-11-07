require 'conoha/version'
require 'conoha/util'
require 'json'

class Conoha
  def self.init!
    load_config!
  end

  def self.authenticate!
    uri = 'https://identity.tyo1.conoha.io/v2.0/tokens'
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
    @@authtoken = JSON.parse(res.body)["access"]["token"]["id"]
    save_config!
  end

  def self.servers
    uri = "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers"
    res = https_get uri, authtoken
    JSON.parse(res.body)["servers"]
  end

  def self.vps_list
    servers.map { |e| e["id"] }
  end

  def self.create(os, ram)
    uri = "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers"
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
    }
    res = https_post uri, payload, authtoken
    JSON.parse(res.body)["server"]["id"]
  end

  def self.delete(server_id)
    uri = "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}"
    res = https_delete uri, authtoken
    res.code == '204' ? 'OK' : 'Error'
  end

  def self.ip_address_of(server_id)
    uri = "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}"
    res = https_get uri, authtoken
    JSON.parse(res.body)["server"]["addresses"].values[0].map{ |e| e["addr"] }
  end

  def self.boot(server_id)
    uri = "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}/action"
    res = https_post uri, {"os-start": nil}, authtoken
    res.code == '202' ? 'OK' : 'Error'
  end

  def self.shutdown(server_id)
    uri = "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}/action"
    res = https_post uri, {"os-stop": nil}, authtoken
    res.code == '202' ? 'OK' : 'Error'
  end

  def self.images
    uri = "https://compute.tyo1.conoha.io/v2/#{tenant_id}/images"
    res = https_get uri, authtoken
    JSON.parse(res.body)["images"].map { |e| [e["name"], e["id"]] }
  end

  def self.create_image(server_id, name)
    uri = "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers/#{server_id}/action"
    res = https_post uri, {"createImage": {"name": name}}, authtoken
    res.code == '202' ? 'OK' : 'Error'
  end

  def self.delete_image(image_ref)
    uri = "https://image-service.tyo1.conoha.io/v2/images/#{image_ref}"
    res = https_delete uri, authtoken
    res.code == '204' ? 'OK' : 'Error'
  end

  def self.create_from_image(image_ref, ram)
    uri = "https://compute.tyo1.conoha.io/v2/#{tenant_id}/servers"
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
    }
    res = https_post uri, payload, authtoken
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
    @@authtoken
  end

  def self.public_key
    @@public_key
  end

  def self.image_ref_from_os(os)
    dictionary = {
      'ubuntu'   => '4952b4e5-67bb-4f84-991f-9f3f1647d63d', # Ubuntu 14.04 amd64
      'centos66' => '14961158-a69c-4af1-b375-b9a72982837d', # CentOS 6.6
      'centos67' => '91944101-df61-4c41-b7c5-76cebfc48318', # CentOS 6.7
      'centos71' => 'edc9457e-e4a8-4974-8217-c254d215b460', # CentOS 7.1
      'arch'     => 'fe22a9e4-8ba1-4ea3-90ce-d59d5e5b35b9', # Arch
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
    (1..60).map{['0'..'9','a'..'z','A'..'Z'].map(&:to_a).flatten.sample}.join
  end
end
