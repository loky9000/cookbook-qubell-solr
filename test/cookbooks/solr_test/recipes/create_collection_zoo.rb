include_recipe "tomcat-component"
include_recipe "solr"
include_recipe "solr::create_collection"
include_recipe "minitest-handler"