#
# Cookbook Name:: account_service
# Recipe:: default
#
# Copyright 2009, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ruby_setup = ["ruby", "ruby1.8-dev", "libopenssl-ruby1.8", "rdoc", "ri", "irb", "build-essential", "wget"]
sqlite3_setup = ["sqlite3", "libsqlite3-dev"]
couchdb_prereq = ["build-essential", "libicu38", "erlang","libicu-dev", "libmozjs-dev", "libcurl4-openssl-dev", "libncurses5-dev"]
webrat_setup = ["libxslt1-dev", "libxml2-dev"]
opscode_audit_gems = ["thin", "amqp", "open4"]
dynomite_directories = ["/var/log","/var/log/dynomite","/var/db","/var/db/dynomite"]

#Not currently used
opscode_gems = ["mixlib-log", "mixlib-cli", "mixlib-config", "opscode-rest"]


#This is to be removed when these gems become public
local_gems = {"mixlib-log-1.0.3.gem" => "mixlib-log" , "mixlib-cli-1.0.4.gem" => "mixlib-cli", "mixlib-config-1.0.7.gem" => "mixlib-config", "rest-client-0.9.2.gem" => "rest-client"}



#ruby
ruby_setup.each do |n|
  apt_package n do 
    action :install
  end 
end 

#RubyGems

#install RubyGems (build from source)

remote_file "/tmp/rubygems-1.3.3.tgz" do
  source "rubygems-1.3.3.tgz"
end

script "install_rubygems" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  tar zxvf rubygems-1.3.3.tgz
  cd rubygems-1.3.3
  ruby setup.rb
  ln -sfv /usr/bin/gem1.8 /usr/bin/gem
  EOH
end

#This should install rabbitmq-server and erlang, as of 5/19/2009, current version does not work with erlang R13B
#apt_package "rabbitmq-server" do
#  action :install
#end


#CouchDB
#Uncomment the "install couchdb" script below to enable coudhdb installation in this run.
#However, since couchdb should be already installed somewhere (for chef-server), a single recipe for installing and one for starting couchdb 0.9.0 is available.

#install pre-requisites
couchdb_prereq.each do |n|
  apt_package n do
    action :install
  end
end

#install erlang
remote_file "/tmp/otp_src_R13B.tar.gz" do
  source "otp_src_R13B.tar.gz"
end 

script "install_erlang_R13B" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  tar -zxf otp_src_R13B.tar.gz
  cd otp_src_R13B
  ./configure
  make
  make install
  EOH
end

=begin
#install couchdb (build from source)
remote_file "/tmp/apache-couchdb-0.9.0.tar.gz" do
  source "apache-couchdb-0.9.0.tar.gz"
end

script "install_couchdb_090" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  tar -zxf apache-couchdb-0.9.0.tar.gz
  cd apache-couchdb-0.9.0
  ./configure
  make
  make install
  EOH
end
=end

#Instal couchrest
gem_package "couchrest" do
  action :install
end

#Build from source and install RabbitMQ Server
remote_file "/tmp/rabbitmq-server-1.5.5.tar.gz" do
  source "rabbitmq-server-1.5.5.tar.gz"
end

#install rabbitmq-server (in /usr/local, /usr/local/sbin, /usr/local/man)
script "install_rabbitmq-server_155" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  tar -zxf rabbitmq-server-1.5.5.tar.gz
  cd rabbitmq-server-1.5.5
  make
  make install TARGET_DIR=/usr/local SBIN_DIR=/usr/local/sbin MAN_DIR=/usr/local/man
  EOH
end


#Cucumber
gem_package "cucumber" do
  version "0.3.3"
  action :install
end 

#Merb
sqlite3_setup.each { |n|
  apt_package n do
    action :install
  end
} 

gem_package "mongrel" do
  action :install
end

gem_package "merb" do
  action :install
end

#Jeweler
gem_package "jeweler" do
  action :install
end

#Sishen-hbase-ruby
gem_package "sishen-hbase-ruby" do
  source "http://gems.github.com"
  action :install
end 

#uuidtools
gem_package "uuidtools" do
  action :install
end


#webrat
webrat_setup.each do |n|
  apt_package n do
    action :install
  end
end

gem_package "webrat" do
 action :install
end


#Opscode-rest
remote_file "/tmp/opscode-rest-0.1.0.gem" do
  source "opscode-rest-0.1.0.gem"
end 

gem_package "/tmp/opscode-rest-0.1.0.gem" do
  package_name "opscode-rest"
  version "0.1.0"
  action :install
end


#Other local Opscode gems
local_gems.each do |k,v|

  remote_file "/tmp/" + k do
    source k
  end

  gem_package "/tmp/" + k do
    package_name v
    action :install
  end

end

#Dynomite
remote_file "/usr/local/dynomite.tar.tgz" do
  source "dynomite.tar.tgz"
end 

#install dynomite
script "install_dynomite" do
  interpreter "bash"
  user "root"
  cwd "/usr/local"
  code <<-EOH
  tar zxvf dynomite.tar.tgz
  EOH
end

#Ruby-dynomite
remote_file "/tmp/dynomite-0.0.1.gem" do
  source "dynomite-0.0.1.gem"
end 

gem_package "/tmp/dynomite-0.0.1.gem" do
  package_name "dynomite"
  version "0.0.1"
  action :install
end


#create necessary directories for dynomite, if non-exists
dynomite_directories.each do |d|
  if !File.directory? d 
    directory d do
      owner "root"
      group "root"
      mode "0644"
      action :create
    end
  end
end


#Install opscode-audit pre-requisites
opscode_audit_gems.each do |n|
  gem_package n do
    action :install
  end
end

#Install opscode-audit
remote_file "/tmp/opscode-audit-0.0.1.gem" do
  source "opscode-audit-0.0.1.gem"
end 

gem_package "/tmp/opscode-audit-0.0.1.gem" do
  package_name "opscode-audit"
  version "0.0.1"
  action :install
end

#Install opscode-certificate
remote_file "/tmp/opscode-certificate-0.0.1.gem" do
  source "opscode-certificate-0.0.1.gem"
end

gem_package "/tmp/opscode-certificate-0.0.1.gem" do
  package_name "opscode-certificate"
  version "0.0.1"
  action :install
end

#Install opscode-account
remote_file "/tmp/opscode-account-0.0.1.gem" do
  source "opscode-account-0.0.1.gem"
end

gem_package "/tmp/opscode-account-0.0.1.gem" do
  package_name "opscode-account"
  version "0.0.1"
  action :install
end

#copy opscode-guid-erlang
remote_file "/usr/local/opscode-guid.tar.gz" do
  source "opscode-guid.tar.gz"
end

#install opscode-guid-erlang
script "install_opscode_guid" do
  interpreter "bash"
  user "root"
  cwd "/usr/local"
  code <<-EOH
  tar zxvf opscode-guid.tar.gz
  ln -s /usr/local/opscode-guid/bin/opscode-guid /usr/local/bin/opscode-guid
  EOH
end


#install ruby-hmac
gem_package "ruby-hmac" do
  action :install
end

#install mixlib-auth
remote_file "/tmp/mixlib-auth-1.0.0.gem" do
  source "mixlib-auth-1.0.0.gem"
end

gem_package "/tmp/mixlib-auth-1.0.0.gem" do
  package_name "mixlib-auth"
  version "1.0.0"
  action :install
end



#install merb_cucumber
remote_file "/tmp/merb_cucumber-0.5.1.2.gem" do
  source "merb_cucumber-0.5.1.2.gem"
end

gem_package "/tmp/merb_cucumber-0.5.1.2.gem" do
  package_name "merb_cucumber"
  version "0.5.1.2"
  action :install
end

#install rest-client
remote_file "/tmp/rest-client-0.9.2.gem" do
  source "rest-client-0.9.2.gem"
end

gem_package "/tmp/rest-client-0.9.2.gem" do
  package_name "rest-client-0.9.2"
  version "0.9.2"
  action :install
end

