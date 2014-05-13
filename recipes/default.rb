#
# Cookbook Name:: solr-component
# Recipe:: default
#

require "pathname"

# Extract war file from solr archive
solr_url = "#{node["cookbook-qubell-solr"]["url"]}#{node["cookbook-qubell-solr"]["version"]}/solr-#{node["cookbook-qubell-solr"]["version"]}.tgz"
version = "#{node["cookbook-qubell-solr"]["version"]}"
bash "get solr-src" do
    cwd "/tmp"
    code <<-EOH
        curl #{solr_url} -o solr-#{version}.tgz
        tar -zxvf /tmp/solr-#{version}.tgz -C /tmp
      EOH
    retries 3
end
# Since solr 4.3.0 we need slf4j jar http://wiki.apache.org/solr/SolrLogging#Solr_4.3_and_above
# Extract required libs

ruby_block "get logging libs" do
  block do
    folder = "/tmp/solr-#{node["cookbook-qubell-solr"]["version"]}/example/lib/ext/"
    libs=(Dir.entries(folder).select {|f| !File.directory? f}).map {|f| "file://" + File.join(folder, f)}
    node.set["cookbook-qubell-solr"]["lib_uri"] = libs
  end
  subscribes :create, resources(:bash => "get solr_src")
end

#Copy sorl.war to webapps
directory "#{node["cookbook-qubell-solr"]["path"]}/webapps" do
  mode 00755
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  recursive true
  action :create
end

execute "copy sorl.war" do
  command "cp /tmp/solr-#{node["cookbook-qubell-solr"]["version"]}/dist/solr-#{node["cookbook-qubell-solr"]["version"]}.war #{node["cookbook-qubell-solr"]["path"]}/webapps/solr.war"
  creates "#{node["cookbook-qubell-solr"]["path"]}/webapps/solr.war"
end

node.set["cookbook-qubell-solr"]["war_uri"] = "#{node["cookbook-qubell-solr"]["path"]}/webapps/solr.war"

#create solr/cores dir
directory "#{node["cookbook-qubell-solr"]["path"]}/cores" do
  owner "#{node["tomcat"]["user"]}"
  group "#{node["tomcat"]["user"]}"
  mode "00755"
  action :create
end

#create cores config
template "#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml" do
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  source "solr.xml.erb"
end

directory "#{node["cookbook-qubell-solr"]["logdir"]}" do
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode 00755
  action :create
end

#create log4j props
template "#{node["cookbook-qubell-solr"]["path"]}/webapps/log4j.properties" do
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  source "log4j.properties.xml.erb"
end

execute "ln home" do
  command "ln -sf #{node["cookbook-qubell-solr"]["path"]} #{node["tomcat"]["base"]}/solr"
end

execute "change solr owner" do
  command "chown -R #{node["tomcat"]["user"]}:#{node["tomcat"]["group"]} #{node["cookbook-qubell-solr"]["path"]}"
end
