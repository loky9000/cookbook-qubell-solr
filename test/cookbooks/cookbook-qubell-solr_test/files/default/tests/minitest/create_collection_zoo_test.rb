require 'minitest/spec'

def assert_include_content(file, content)
  assert File.read(file).include?(content), "Expected file '#{file}' to include the specified content #{content}"
end

describe_recipe "cookbook-qubell-solr::create_collection" do
  it "creates collection folder" do
    node["cookbook-qubell-solr"]["collection"].each do |collection|
      assert_directory "#{node["cookbook-qubell-solr"]["path"]}/cores/#{collection}", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "755"
    end
  end
  it "creates collection config folder" do
    node[cookbook-qubell-"solr"]["collection"].each do |collection|
      assert_directory "#{node["cookbook-qubell-solr"]["path"]}/cores/#{collection}/conf", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "755"
    end
  end
  it "creates collection schema.xml" do
    node["cookbook-qubell-solr"]["collection"].each do |collection|
      assert_file "#{node["cookbook-qubell-solr"]["path"]}/cores/#{collection}/conf/schema.xml", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "600"
    end
  end
  it "creates collection solrconfig.xml" do
    node["cookbook-qubell-solr"]["collection"].each do |collection|
      assert_file "#{node["cookbook-qubell-solr"]["path"]}/cores/#{collection}/conf/solrconfig.xml", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "600"
    end
  end
  it "add to schema.xml correct values" do
    node["cookbook-qubell-solr"]["collection"].each do |collection|
      assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/cores/#{collection}/conf/schema.xml", "#{collection}")
    end
  end
  it "add to solrconfig.xml correct values" do
    node["cookbook-qubell-solr"]["collection"].each do |collection|
      assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/cores/#{collection}/conf/solrconfig.xml", "#{collection}")
    end
  end
  it "add to solr.xml correct values" do
    node["cookbook-qubell-solr"]["collection"].each do |collection|
      assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml", "core name=\"#{collection}\" instanceDir=\"#{collection}\"")
    end
  end
  it "install unzip" do
    package("unzip").must_be_installed
  end
  it "extract solr.war to /tmp/solr_war" do
    assert_directory "/tmp/solr_war", "root", "root", "755"
  end
  it "creates zkcli.sh" do
    assert_file "#{node["cookbook-qubell-solr"]["path"]}/webapps/zkcli.sh", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "755"
  end
  it "add correct values to zkcli.sh" do
    assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/webapps/zkcli.sh", "/tmp/solr-#{node["cookbook-qubell-solr"]["version"]}/example/cloud-scripts")
    assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/webapps/zkcli.sh", "#{node["cookbook-qubell-solr"]["path"]}/webapps/log4j.properties")
  end
end

