require 'serverspec'
require 'yaml'

properties = YAML.load_file('properties.yml')

host = ENV['TARGET_HOST']
set_property properties[host]

set :backend, :exec

