#
# Cookbook Name:: solr-component
# Recipe:: default
#

require "pathname"

# Since solr 4.3.0 we need slf4j jar http://wiki.apache.org/solr/SolrLogging#Solr_4.3_and_above
slf4j_url = "#{node["cookbook-qubell-solr"]["slf4j"]["url"]}/slf4j-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}.tar.gz"
remote_file "/tmp/slf4j-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}.tar.gz" do
  source slf4j_url
  action :create_if_missing
end

# Extract required libs
libs = []
["slf4j-jdk14-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}.jar", "log4j-over-slf4j-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}.jar", "slf4j-api-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}.jar", "jcl-over-slf4j-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}.jar"].each do |file|
  execute "extract #{file}" do
    command "tar -xzvf /tmp/slf4j-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}.tar.gz -C /tmp/ slf4j-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}/#{file}"
    creates "/tmp/slf4j-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}/#{file}"
  end
libs << "file:///tmp/slf4j-#{node["cookbook-qubell-solr"]["slf4j"]["version"]}/#{file}"
end
node.set["cookbook-qubell-solr"]["lib_uri"] = libs


# Extract war file from solr archive
solr_url = "#{node["cookbook-qubell-solr"]["url"]}#{node["cookbook-qubell-solr"]["version"]}/solr-#{node["cookbook-qubell-solr"]["version"]}.tgz"
remote_file "solr_src" do
  path "/tmp/solr-#{node["cookbook-qubell-solr"]["version"]}.tgz"
  source solr_url
  action :create_if_missing
end

execute "extract solr_src" do
  command "tar -xzvf /tmp/solr-#{node["solr"]["version"]}.tgz -C /tmp"
  creates "/tmp/solr-#{node["cookbook-qubell-solr"]["version"]}"
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
  command "cp /tmp/solr-#{node["cookbook-qubell-solr"]["version"]}/dist/solr-#{node["cookbook-qubell-solr"]["version"]}.war #{node[cookbook-qubell-solr"]["path"]}/webapps/solr.war"
  creates "#{node["cookbook-qubell-solr"]["path"]}/webapps/solr.war"
end

node.set["cookbook-qubell-solr"]["war_uri"] = "#{node["cookbook-qubell-solr"]["path"]}/webapps/solr.war"

#Populate collections
if ( node["cookbook-qubell-solr"]["collection"][0].start_with?('http:','https:','ftp:','file:'))
  #if collection uri
  require 'uri'
  collection = node['cookbook-qubell-solr']['collection'][0]
  uri = URI.parse(collection)
  file_name = File.basename(uri.path)
  ext_name = File.extname(file_name)
  target_file = "/tmp/#{file_name}"

  #check is extention zip|tar.gz
  if ( ! %w{.zip .gz }.include?(ext_name))
    fail "not supported"
  end
  #download to target_file
  if ( collection.start_with?('http','ftp'))
    remote_file "#{target_file}" do
      source collection
    end
  elsif ( collection.start_with?('file'))
    target_file = URI.parse(collection).path
  end

  file_name = File.basename(target_file)
    
  #create solr/cores dir
  directory "#{node["cookbook-qubell-solr"]["path"]}/cores" do
    owner "#{node["tomcat"]["user"]}"
    group "#{node["tomcat"]["user"]}"
    mode "00755"
    action :create
  end

  #extract collection archive
  case ext_name
  when ".gz"
    bash "unpack collection #{target_file}" do
      user "root"
      code <<-EOH
      tar -xzvf #{target_file} -C #{node["cookbook-qubell-solr"]["path"]}/cores/
      chown -R #{node["tomcat"]["user"]}:#{node["tomcat"]["user"]} #{node["cookbook-qubell-solr"]["path"]}/cores
      chmod -R 755 #{node["cookbook-qubell-solr"]["path"]}/cores
      EOH
    end
  when ".zip"
    package "zip" do
      action :install
    end
    bash "unpack collection #{target_file}" do
      user "root"
      code <<-EOH
       unzip -o #{target_file} -d #{node["cookbook-qubell-solr"]["path"]}/cores/
      chown -R #{node["tomcat"]["user"]}:#{node["tomcat"]["user"]} #{node["cookbook-qubell-solr"]["path"]}/cores
      chmod -R 755 #{node["cookbook-qubell-solr"]["path"]}/cores
      EOH
    end
  end

  include_recipe "file"
  
  file_replace "remove hostPort in solr.xml" do
    replace 'hostPort=".*"'
    with ''
    path "#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml"
  end
  
  file_replace "remove hostcontext" do
    replace 'hostContext=".*"'
    with ''
    path "#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml"
  end

  file_replace "set hostPort hostContext" do
    replace '<cores'
    with "<cores hostPort=\"#{node["cookbook-qubell-solr"]["port"]}\" hostContext=\"#{node["cookbook-qubell-solr"]["hostcontext"]}\" "
    path "#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml"
  end 

else
  #If collection not uri
  #Create collections
  node["cookbook-qubell-solr"]["collection"].each do |collection|
    directory "#{node["cookbook-qubell-solr"]["path"]}/cores/#{collection}/conf/" do
      owner node["tomcat"]["user"]
      group node["tomcat"]["group"]
      mode 00755
      recursive true
      action :create
    end

    template "#{node["cookbook-qubell-solr"]["path"]}/cores/#{collection}/conf/schema.xml" do
      owner node["tomcat"]["user"]
      group node["tomcat"]["group"]
      source "schema.xml.erb"
      variables({
        :collection => "#{collection}"
      })
    end

    template "#{node["cookbook-qubell-solr"]["path"]}/cores/#{collection}/conf/solrconfig.xml" do
      owner node["tomcat"]["user"]
      group node["tomcat"]["group"]
      source "solrconfig.xml.erb"
      variables({
        :collection => "#{collection}"
      })
    end
  end

  template "#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml" do
    owner node["tomcat"]["user"]
    group node["tomcat"]["group"]
    source "solr.xml.erb"
  end
end

if ( ! node["cookbook-qubell-solr"]["zookeeper"]["nodes"].empty? )
  include_recipe "solr::zoo"
end

execute "ln home" do
  command "ln -sf #{node["cookbook-qubell-solr"]["path"]} #{node["tomcat"]["base"]}/solr"
end

execute "change solr owner" do
  command "chown -R #{node["tomcat"]["user"]}:#{node["tomcat"]["group"]} #{node["cookbook-qubell-solr"]["path"]}"
end
