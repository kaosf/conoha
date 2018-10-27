# ConoHa VPS CLI Tool

[![Gem Version](https://badge.fury.io/rb/conoha.svg)](http://badge.fury.io/rb/conoha)
[![Build Status](https://travis-ci.org/kaosf/conoha.svg)](https://travis-ci.org/kaosf/conoha)
[![Coverage Status](https://coveralls.io/repos/github/kaosf/conoha/badge.svg?branch=master)](https://coveralls.io/github/kaosf/conoha?branch=master)
[![Code Climate](https://codeclimate.com/github/kaosf/conoha/badges/gpa.svg)](https://codeclimate.com/github/kaosf/conoha)

CLI tool for management ConoHa VPS.

[ConoHa VPS](https://www.conoha.jp/en)

[API Document](https://www.conoha.jp/conoben/archives/10025)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'conoha'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install conoha

## Usage

Create `username`, `password` and `tenant_id` values with the [Web control panel](https://manage.conoha.jp/Service/) at first.

Register a public key for SSH connection at least one. Set its key label name to `public_key` value.

Create `~/.conoha-config.json` like following:

```.conoha-config.json:json
{
  "username": "gncu123456789",
  "password": "your-password",
  "region": "tyo1",
  "tenant_id": "0123456789abcdef",
  "public_key": "your-registered-public-key-name"
}
```

You can select a region from `"tyo1"` (Tokyo), `"sin1"` (Singapore) and `"sjc1"` (USA).

You should run `chmod 600 ~/.conoha-config.json`.

```
# Authenticate after preparation ~/.conoha-config.json
conoha authenticate

# Create a VPS
conoha create ubuntu g-1gb
# Remember the UUID of created VPS

# Create VPSs with other options
conoha create centos72 g-2gb
conoha create arch g-4gb
conoha create ubuntu g-1gb nametagasyoulike

# Create VPS 512MB RAM
# You must use the image tag with "-20gb"
conoha create centos72-20gb g-512mb
conoha create arch-20gb g-512mb
conoha create ubuntu-20gb g-512mb nametagasyoulike

# You can check VPS UUIDs
conoha vpslist

# Check VPS IPv4 address
conoha ipaddress 01234567-89ab-cdef-0123-456789abcdef

# Check VPS status
conoha status 01234567-89ab-cdef-0123-456789abcdef

# Shutdown VPS
conoha shutdown 01234567-89ab-cdef-0123-456789abcdef

# Boot VPS
conoha boot 01234567-89ab-cdef-0123-456789abcdef

# Reboot VPS
conoha reboot 01234567-89ab-cdef-0123-456789abcdef      # Shutdown -> Boot
conoha reboot 01234567-89ab-cdef-0123-456789abcdef hard # Force shutdown -> Boot
# For more information, ref. https://www.conoha.jp/docs/compute-reboot_vm.html

# Rebuild (Re-install the OS)
conoha rebuild 01234567-89ab-cdef-0123-456789abcdef ubuntu

# Delte VPS
conoha delete 01234567-89ab-cdef-0123-456789abcdef

# Create image with a name
conoha imagecreate 01234567-89ab-cdef-0123-456789abcdef ubuntu-backup

# Check image UUIDs
conoha imagelist

# Delete image
conoha imagedelete fedcba98-7654-3210-fedc-ba9876543210

# Create a VPS from a saved image
conoha createfromimage fedcba98-7654-3210-fedc-ba9876543210 g-1gb
conoha createfromimage ubuntu-backup g-1gb
# You can remove the last argument (default value is "g-1gb")
conoha createfromimage fedcba98-7654-3210-fedc-ba9876543210
# You can specify the user_data.
# More information:
#   https://www.conoha.jp/guide/startupscript.php
#   https://www.conoha.jp/docs/compute-create_vm.html
# "g-1gb" (or any other RAM specification) is required now, because
# "--user-data" and "BASE64_STRING" are detected by their argument position
# (4th and 5th), sorry for my poor implementation...
conoha createfromimage fedcba98-7654-3210-fedc-ba9876543210 g-1gb --user-data BASE64_STRING
# You can get BASE64_STRING from like a following command e.g.
cat <<EOF | base64 -w
#!/bin/bash

apt-get -y install nginx
EOF

# SSH
conoha ssh 01234567-89ab-cdef-0123-456789abcdef root     # ssh root@ipaddress
conoha ssh 01234567-89ab-cdef-0123-456789abcdef yourname # ssh yourname@ipaddress
conoha ssh 01234567-89ab-cdef-0123-456789abcdef          # ssh ipaddress

# Mosh
conoha mosh 01234567-89ab-cdef-0123-456789abcdef root # mosh root@ipaddress

# Launch Web browser
conoha browse 01234567-89ab-cdef-0123-456789abcdef      # xdg-open http://ipaddress
conoha browse 01234567-89ab-cdef-0123-456789abcdef 3000 # xdg-open http://ipaddress:3000

# Dump VPS (shutdown, imagecreate and delete)
conoha dump 01234567-89ab-cdef-0123-456789abcdef something-backup
# "something-backup" is the name for "imagecreate"

# Restore VPS (just a synonym of "createfromimage")
conoha restore something-backup

# Get name tag
conoha nametag 01234567-89ab-cdef-0123-456789abcdef
```

## Test

```sh
rake
```

## Development

<del>

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

</del>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kaosf/conoha.

## TODO

- [ ] help message
- [ ] subcommand help messages
- [ ] CLI support library (e.g. thor)

## WIP feature

Run `conoharant init` to generate `Conoharantfile`.

You should ignore `.conoharant` directory if you manage `Conoharantfile` with VCS.

### Simple usage

```sh
conoharant init
conoharant up
conoharant status
conoharant ssh
conoharant ssh username
conoharant mosh
conoharant mosh username
conoharant sftp
conoharant sftp username
conoharant dump
conoharant restore
conoharant clean
conoharant browse
conoharant browse 3000
conoharant halt
conoharant shutdown
conoharant destroy
conoharant rebuild
conoharant ipaddress
```

## Experimental feature: multiple accounts management

Edit `~/.conoha-config.json` like following:

```sh
{
  "username": "gncu123456789",
  "password": "your-password",
  "tenant_id": "0123456789abcdef",
  "public_key": "your-registered-public-key-name",
  "accounts": {
    "user1": {
      "username": "gncu123456789",
      "password": "your-password",
      "tenant_id": "0123456789abcdef",
      "public_key": "your-registered-public-key-name"
    },
    "user2": {
      "username": "gncu123456790",
      "password": "your-user2-password",
      "tenant_id": "0123456789abcdf0",
      "public_key": "your-registered-public-key-name"
    }
  }
}
```

```sh
conoha authenticate user1

conoha whoami
#=> user1

conoha create ubuntu g-1gb
# Create VM of user1

conoha authenticate user2

conoha whoami
#=> user2

conoha create ubuntu g-1gb
# Create VM of user2
```

## License

[MIT](LICENSE.txt)
