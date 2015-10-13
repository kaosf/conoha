# ConoHa VPS CLI Tool

[![Gem Version](https://badge.fury.io/rb/conoha.svg)](http://badge.fury.io/rb/conoha)
[![Dependency Status](https://gemnasium.com/kaosf/conoha.svg)](https://gemnasium.com/kaosf/conoha)
[![Build Status](https://travis-ci.org/kaosf/conoha.svg)](https://travis-ci.org/kaosf/conoha)
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
  "tenant_id": "0123456789abcdef",
  "public_key": "your-registered-public-key-name"
}
```

You should run `chmod 600 ~/.conoha-config.json`.

```
# Authenticate after preparation ~/.conoha-config.json
conoha authenticate

# Create a VPS
conoha create ubuntu g-1gb
# Remember the UUID of created VPS

# Create VPSs with other options
conoha create centos71 g-2gb
conoha create arch g-4gb

# You can check VPS UUIDs
conoha vpslist

# Check VPS IPv4 address
conoha ipaddress 01234567-89ab-cdef-0123-456789abcdef

# Shutdown VPS
conoha shutdown 01234567-89ab-cdef-0123-456789abcdef

# Boot VPS
conoha boot 01234567-89ab-cdef-0123-456789abcdef

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

# SSH
conoha ssh 01234567-89ab-cdef-0123-456789abcdef root     # ssh root@ipaddress
conoha ssh 01234567-89ab-cdef-0123-456789abcdef yourname # ssh yourname@ipaddress
conoha ssh 01234567-89ab-cdef-0123-456789abcdef          # ssh ipaddress

# Mosh
conoha mosh 01234567-89ab-cdef-0123-456789abcdef root # mosh root@ipaddress

# Launch Web browser
conoha browse 01234567-89ab-cdef-0123-456789abcdef      # xdg-open http://ipaddress
conoha browse 01234567-89ab-cdef-0123-456789abcdef 3000 # xdg-open http://ipaddress:3000
```

## Development

<del>
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
</del>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kaosf/conoha.

## TODO

### Features

- [x] authenticate
- [x] create vps
- [x] show vps list
- [x] check ip address
- [x] delete vps
- [x] boot vps
- [x] shutdown vps
- [x] create image
- [x] create vps from image
- [x] show image list
- [x] delete image
- [ ] public keys
- [x] make as a gem
- [x] remove `curl` command from authenticate
- [ ] help message
- [ ] subcommand help messages

### Code

- [ ] DRY HTTP codes
- [ ] test (but, how and what should I write?)

## License

[MIT](http://opensource.org/licenses/MIT)

Copyright (C) 2015 ka
