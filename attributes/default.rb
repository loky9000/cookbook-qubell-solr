#default["solr"]["url"] = "http://apache.mesi.com.ar/lucene/solr/"
default["cookbook-qubell-solr"]["url"] = "http://archive.apache.org/dist/lucene/solr/"
default["cookbook-qubell-solr"]["version"] = "4.6.0"
default["cookbook-qubell-solr"]["path"] = "/opt/solr"
#default["cookbook-qubell-solr"]["slf4j"]["url"] = "http://www.slf4j.org/dist"
#default["cookbook-qubell-solr"]["slf4j"]["version"] = "1.6.6"
default["cookbook-qubell-solr"]["collection"] = []
default["cookbook-qubell-solr"]["zookeeper"]["port"] = "2181"
default["cookbook-qubell-solr"]["zookeeper"]["timeout"] = "10000" 
default["cookbook-qubell-solr"]["zookeeper"]["hosts"] = []
if (! node["cookbook-qubell-solr"]["zookeeper"]["hosts"].empty?)
  zoo_nodes = []
  node["cookbook-qubell-solr"]["zookeeper"]["hosts"].each do |zoonode|
    zoo_nodes << "#{zoonode}:#{node["cookbook-qubell-solr"]["zookeeper"]["port"]}"
  end
  set["cookbook-qubell-solr"]["zookeeper"]["nodes"] = zoo_nodes.join(",")
else
  set["cookbook-qubell-solr"]["zookeeper"]["nodes"] = ""
end

default["cookbook-qubell-solr"]["port"]="8983"
default["cookbook-qubell-solr"]["hostcontext"]="solr"
default["cookbook-qubell-solr"]["logdir"]="#{node["solr"]["path"]}/logs"
default["cookbook-qubell-solr"]["loglevel"]="INFO"
default["cookbook-qubell-solr"]["zookeeper"]["loglevel"]="WARN"
default["cookbook-qubell-solr"]["hadoop"]["loglevel"]="WARN"
default["tomcat"]["base_version"] = 6
case node['platform']
when "centos","redhat","fedora"
  default["tomcat"]["user"] = "tomcat"
  default["tomcat"]["group"] = "tomcat"
  default["tomcat"]["base"] = "/usr/share/tomcat#{node["tomcat"]["base_version"]}"
when "debian","ubuntu"
  default["tomcat"]["user"] = "tomcat#{node["tomcat"]["base_version"]}"
  default["tomcat"]["group"] = "tomcat#{node["tomcat"]["base_version"]}"
  default["tomcat"]["base"] = "/var/lib/tomcat#{node["tomcat"]["base_version"]}"
end
