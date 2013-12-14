# Phrase: preceeding install
#======================================================================
# directory for preseeding file
directory "/var/cache/local/preseeding" do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

# generating template
template "/var/cache/local/preseeding/snort.seed" do
  source "snort.seed.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :run, "execute[preseed snort]", :immediately
end

# seeding to devconf database
execute "preseed snort" do
  command "debconf-set-selections /var/cache/local/preseeding/snort.seed"
  action :nothing
end

package snort_package do
  action :upgrade
end

# Phrase: Cookbook File
#======================================================================
cookbook_file "/usr/local/bin/apache2_module_conf_generate.pl" do
  source "apache2_module_conf_generate.pl"
  mode 0755
  owner "root"
  group "root"
end

# Finding Order
#=====================
# * host-foo.example.com/apache2_module_conf_generate.pl
# * ubuntu-8.04/apache2_module_conf_generate.pl
# * ubuntu/apache2_module_conf_generate.pl
# * default/apache2_module_conf_generate.pl
#
# Rule
#=====================
#   1. host-node[:fqdn]
#   2. node[:platform]-node[:version]
#   3. node[:platform]
#   4. default
#
# Example
#=====================
# * files/ (or templates/)
#    * host-foo.example.com
#    * ubuntu-8.04
#    * ubuntu
#    * default
#

# Phrase: package
#======================================================================
package "runit" do
  action :install
  if platform?("ubuntu", "debian")
    response_file "runit.seed"
  end
  notifies value_for_platform(
    "debian" => { "4.0" => :run, "default" => :nothing  },
    "ubuntu" => {
      "default" => :nothing,
      "9.04" => :run,
      "8.10" => :run,
      "8.04" => :run },
    "gentoo" => { "default" => :run }
  ), resources(:execute => "start-runsvdir"), :immediately
  notifies value_for_platform(
    "debian" => { "squeeze/sid" => :run, "default" => :nothing },
    "default" => :nothing
  ), resources(:execute => "runit-hup-init"), :immediately
end

# Phrase: [ Attribute ] Precedence
# ======================================================================
# precedence
# ### phase 1: Default
#     Attributes > Environment > Role > Recipe 
# 
# ### phase 2: Normal
#     Attribute file > Recipe
# 
# ### phase 3: Override
#     Attributes > Role > Environment > Recipe 
# 
# Phrase: [ Attribute | Node ] Context
# ======================================================================
# in cookbooks/hoge/attributes/default.rb
#  in attribute file, code is evaluated on context `node`.
default[:apache][:dir]          = "/etc/apache2"
default[:apache][:listen_ports] = [ "80","443" ]

# in cookbooks/hoge/recipe/default.rb
node.default[:apache][:dir]          = "/etc/apache2"
node.default[:apache][:listen_ports] = [ "80","443" ]

# Conditional in attribute file
if attribute?("ec2")
   # ... set stuff related to EC2
end
# Conditional in recipe file
if node.attribute?("ec2")
   # ... set stuff related to EC2
end

# Phrase: [Attribute] include_attribute file from Attribute file
# ======================================================================
## Attribute File ordering
# [NOTE] include_attribute is not available in `recipe`.
### attribute files are loaded in alphabetical order.
# if you want to ensure some attribute is available in your recipe.
# use `include_attribute`.
include_attribute "apache2"
include_attribute "rails::tunables"


# Phrase: [Attribute] Reloading Attribute Files From Recipes
# ======================================================================
package 'iptables' do
  notifies :create, 'ruby_block[try_firewall_again]', :immediately
end

ruby_block 'try_firewall_again' do
  block do
    node.load_attribute_by_short_filename('default', 'firewall')
  end
  action :nothing
end

# Phrase: URL
# ======================================================================
# http://wiki.opscode.com/display/chef/Resources
#

#  Phrase: databag
# ======================================================================
images = data_bag_item('openstack', 'images')

#  Phrase: load kernel module if not loaded
# ======================================================================
require 'chef/shell_out'
cmd = Chef::ShellOut.new("lsmod")
modules = cmd.run_command
execute "modprobe nbd" do
  action :run
  not_if {modules.stdout.include?("nbd")}
end

# Phrase: remote_directory
#======================================================================
# Desc: copy files in directory 'files/default/plugins' recursively.
remote_directory "/usr/lib/nagios/plugins" do
  source "plugins"
  owner "nagios"
  group "nagios"
  mode 0755
  files_mode 0755
end

# Phrase: Service
# ======================================================================
service "example_service" do
  case node[:platform]
  when "ubuntu"
    if node[:platform_version].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  action [:enable, :start]
end

# Phrase: value_for_platform platform?
# ======================================================================
packages = value_for_platform([ "centos", "redhat", "suse", "fedora" ] => {"default" => "mysqld"}, "default" => "mysql")

package_name = value_for_platform(
  ["centos", "redhat", "suse", "fedora" ] => {
    "default" => "httpd"
  },
  ["ubuntu", "debian"] => {
    "default" => "apache2"
  }
)

ldap_packages = value_for_platform(
  %w(centos redhat suse fedora) => {
  "default" => ["nss_ldap"]
}, %w(debian ubuntu) => {
  "default" => %w(libnss-ldap libpam-ldap ldap-utils nscd)
})

unless platform?(%w{debian ubuntu})

  execute "assign-root-password" do
    command "/usr/bin/mysqladmin -u root password #{node['mysql']['server_root_password']}"
    action :run
    only_if "/usr/bin/mysql -u root -e 'show databases;'"
  end

end

# Phrase: log
# ======================================================================
require "rubygems"
require "colored"
def info(&blk) log("#{blk.call.to_s}".yellow ){ level :info } end
info { node[:ca_ldap][:dc] }
info { node[:ca_ldap]["#{node[:ca_ldap][:dc]}_servers"].inspect }
info { node[:ca_ldap][:security] }

# Phrase: template
# ======================================================================
template "/etc/resolv.conf" do
  source "resolv.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

# template/default/resolve.conf.erb
# search <%= node[:resolver][:search] %>
# <% node[:resolver][:nameservers].each do |nameserver| -%>
# nameserver <%= nameserver %>
# <% end -%>

#  Phrase: gem_package
# ======================================================================
gem_package "syntax" do
  action :install
  options("--prerelease --no-format-executable")
  ignore_failure true
end

gem_package "rake" do
  action :install
  options("--no-rdoc --no-ri")
end
#  Phrase: notify
# ======================================================================
execute "notified" do
  command "ls -l > /tmp/notified_result"
  creates "/tmp/notified_result"
  action :nothing
end
 
file "/tmp/something" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  notifies :run, resources(:execute => "notified")
end

#  Phrase: execute
# ======================================================================
MY_NAME="TAKU Maeda This is my new name #{Time.now}"
execute "HOGHEOGE" do
  command "echo #{MY_NAME} >>/tmp/result"
  creates "/tmp/result"
  action :run
end

# set default_route
execute "set_default_route" do
  command "ip route delete default ; ip route add default via #{node[:my_gateway]}"
  not_if "ip route  | grep ^default | grep -v -q grep"
  action :run
end

#  Phrase: log
# ======================================================================
log "your string to log"
log("a debug string") { level :debug }

#  Phrase: Directory
# ======================================================================
directory "/this/is/very/nested/directory" do
  owner "root"
  group "root"
  recursive true
end

cron "noop" do
  hour "5"; minute "0"
  command "/bin/true"
end

node.set['some_attribute']['sub_attribute'] = "Sub attribute Value"
node.set['attrA']['attrB']['attrC'] = "attr a b c"
node.set[:attrD][:attrE][:attrF] = "attr D E F"
node.set.activemq.wrapper.max_memory = "60"

require_recipe "activemq"
# node.default.activemq.wrapper.max_memory = "60"
# phrase_file: phrase__chef.rb
# vim: set ft=ruby:
