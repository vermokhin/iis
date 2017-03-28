#
# Cookbook Name:: iis-test
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'iis::default'


iis_pool "DB Necromancer" do
  runtime_version "4.5"
  pipeline_mode :Integrated
  action [:add, :start]
end

# creates a new app pool
iis_pool 'myAppPool_v1_1' do
  runtime_version "2.0"
  pipeline_mode :Classic
  action :add
end

# stop and delete the default site
iis_site 'Default Web Site' do
  action [:stop, :delete]
end

directory "#{node['iis']['docroot']}testfu" do
  recursive true
end

directory "#{node['iis']['docroot']}testfu/v1_1" do
  recursive true
end

# create and start a new site that maps to
# the physical location C:\inetpub\wwwroot\testfu
iis_site 'Testfu Site' do
  protocol :http
  port 80
  application_pool "DB Necromancer"
  path "#{node['iis']['docroot']}testfu"
  action [:add,:start]
end

# create and start a new site that maps to
# the physical C:\inetpub\wwwroot\testfu
# also adds bindings to http and https
# binding http to the ip address 10.12.0.136,
# the port 80, and the host header www.domain.com
# also binding https to any ip address,
# the port 443, and the host header www.domain.com
iis_site 'FooBar Site' do
  application_pool "DB Necromancer"
  bindings 'http/10.12.0.136:80:www.domain.com,https/*:443:www.domain.com'
  path "#{node['iis']['docroot']}testfu"
  action [:add,:start]
end

# creates a new app
iis_app "FooBar Site" do
  path "/v1_1"
  application_pool "myAppPool_v1_1"
  physical_path "#{node['iis']['docroot']}testfu/v1_1"
  enabled_protocols "http,net.pipe"
  action :add
end

directory 'C:\wwwroot\shared\test' do
  recursive true
  action :create
end

# add a virtual directory to default application
iis_vdir 'FooBar Site/' do
  action :add
  path '/Content/Test'
  physical_path 'C:\wwwroot\shared\test'
end

# add a virtual directory to an application under a site
iis_vdir 'FooBar Site/v1_1' do
  action :add
  path '/Content/Test'
  physical_path 'C:\wwwroot\shared\test'
end