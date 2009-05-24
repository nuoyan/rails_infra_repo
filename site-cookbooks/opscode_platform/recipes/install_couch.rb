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


include_recipe "runit"
couchdb_prereq = ["build-essential", "libicu38", "erlang","libicu-dev", "libmozjs-dev", "libcurl4-openssl-dev", "libncurses5-dev"]

#CouchDB

#install pre-requisites
couchdb_prereq.each do |n|
  apt_package n do
    action :install
  end
end

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


