require 'spec_helper'

describe file("/etc/localtime") do
  it { should exist }
end

describe file("/etc/sysconfig/clock") do
  its(:content) { should match /ZONE="#{property[:timezone]}"/ }
end

describe port(property[:ssh_port]) do
  it { should be_listening }
end

describe file("/home/#{property[:username]}/.ssh/authorized_keys") do
  it { should exist }
end

describe file("/etc/ssh/sshd_config") do
  its(:content) { should match /^Protocol 2$/ }
  its(:content) { should match /^PermitRootLogin no$/ }
  its(:content) { should match /^PasswordAuthentication no$/ }
  its(:content) { should match /^PubkeyAuthentication yes$/ }
  its(:content) { should match /^MaxAuthTries 3$/ }
  its(:content) { should match /^MaxStartups 3:90:5$/ }
end

describe selinux do
  it { should be_disabled }
end

["logwatch", "zsh", "git", "vim-common", "vim-enhanced", "vim-minimal", "jq", "tar", "gcc", "openssl-devel", "libyaml-devel", "libffi-devel", "zlib-devel", "gdbm-devel", "ncurses-devel", "docker-io"].each do |key|
  describe package("#{key}") do
    it { should be_installed }
  end
end

describe user('develop') do
  it { should have_login_shell 'zsh' }
end

[".zshrc", ".vimrc", ".zshenv"].each do |key|
  describe file("/home/develop/#{key}") do
    it { should exist }
  end
end

describe command('ruby -v') do
  its(:stdout) { should match /ruby 2\.2\.2.+/ }
end

