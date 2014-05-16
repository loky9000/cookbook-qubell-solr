#
# Delete collection
#

solr_cores = "#{node["cookbook-qubell-solr"]["path"]}/cores"

if (! node["cookbook-qubell-solr"]["zookeeper"]["nodes"].empty?)
#clean zoo
  zoo_connect = "#{node["cookbook-qubell-solr"]["zookeeper"]["nodes"]}"
  bash "clean zookeeper data" do
    user "root"
    code <<-EOH
    #{node["cookbook-qubell-solr"]["path"]}/webapps/zkcli.sh -zkhost #{zoo_connect} -cmd clear /
    EOH
  end
end
#delete collection in cores
bash "delete solr collection" do
  user "root"
  code <<-EOH
  rm -rf #{solr_cores}/*
  EOH
end
