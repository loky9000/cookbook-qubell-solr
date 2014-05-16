[![Build Status](https://travis-ci.org/jollyrojer/zookeeper-component.png?branch=master)](https://travis-ci.org/jollyrojer/zookeeper-component)

Solr Cookbook
==============
Installs and configure apache Solr server.
Could be used as:
- Standalone Solr server with/wo multiple cores
- SolrCloud with ZooKeeper cluster

Platform
--------
- Ubuntu 10.04, 12.04 (x32/x64)
- CentOS 5, 6 (x64)

Cookbooks
---------
- depends "file" v2.0
- depends "java" v1.11.7
- depends qubell-bazaar "zookeeper-component" v0.1.0
- depends qubell-bazaar "tomcat-component" v0.2.1"
