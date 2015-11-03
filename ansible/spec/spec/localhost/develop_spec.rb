require 'spec_helper'

describe file("/etc/localtime") do
  it { should exist }
  it { should be_exist }
end

describe file("/etc/sysconfig/clock") do
  its(:content) { should match /ZONE="#{property[:timezone]}"/ }
end

describe port(#{property[:ssh_port]}) do
  it { should be_listening }
end
