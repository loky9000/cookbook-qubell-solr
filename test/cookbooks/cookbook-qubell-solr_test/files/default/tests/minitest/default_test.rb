require 'minitest/spec'

def assert_include_content(file, content)
  assert File.read(file).include?(content), "Expected file '#{file}' to include the specified content"
end

def refute_include_content(file, content)
  refute File.read(file).include?(content), "Expected file '#{file}' not include the specified content #{content}"
end

describe_recipe "cookbook-qubell-solr::default" do
  it "creates solr_src folder" do
    assert File.directory?("/tmp/solr-#{node['cookbook-qubell-solr']['version']}")
  end
  it "creates webapp folder" do
    assert_directory "#{node["cookbook-qubell-solr"]["path"]}/webapps", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "755"
  end
  it "copy solr.war to to webapps" do
    assert_file "#{node["cookbook-qubell-solr"]["path"]}/webapps/solr.war", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "644"
  end
  it "creates solr cores folder" do
    assert_directory "#{node["cookbook-qubell-solr"]["path"]}/cores", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "755"
  end
  it "creates solr cores config solr.xml" do
    assert_file "#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "600"
  end
  it "check cores config solr.xml correct" do
    assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml", "hostPort=\"#{node["cookbook-qubell-solr"]["port"]}\"")
    assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml", "hostContext=\"#{node["cookbook-qubell-solr"]["hostcontext"]}\"")
    refute_include_content("#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml", "zkHost=\"=#{node["cookbook-qubell-solr"]["zookeeper"]["nodes"]}\"")
    refute_include_content("#{node["cookbook-qubell-solr"]["path"]}/cores/solr.xml", "zkClientTimeout=\"#{node["cookbook-qubell-solr"]["zookeeper"]["timeout"]}\"")
  end
  it "creates solr log dir" do
    assert_directory "#{node["cookbook-qubell-solr"]["logdir"]}", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "755"
  end
  it "creates log4j config" do
    assert_file "#{node["cookbook-qubell-solr"]["path"]}/webapps/log4j.properties", "#{node["tomcat"]["user"]}", "#{node["tomcat"]["user"]}", "600"
  end
  it "check log4j config correct" do
    assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/webapps/log4j.properties", "#{node["cookbook-qubell-solr"]["logdir"]}")
    assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/webapps/log4j.properties", "#{node["cookbook-qubell-solr"]["loglevel"]}")
    assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/webapps/log4j.properties", "#{node["cookbook-qubell-solr"]["zookeeper"]["loglevel"]}")
    assert_include_content("#{node["cookbook-qubell-solr"]["path"]}/webapps/log4j.properties", "#{node["cookbook-qubell-solr"]["hadoop"]["loglevel"]}")
  end
end
