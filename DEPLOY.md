To deploy as a war under Tomcat:

# Prerequisites

Jruby 
Postgresql
Tomcat 6

# Get LLT Db handler code and install the db
git clone https://github.com/latin-language-toolkit/llt-db_handler
cd llt-db_handler

psql
  create user prometheus with password 'admin'
  alter user prometheus with createdb

rake db:prometheus:create [hostname]
rake db:prometheus:seed [hostname]

# Get the LLT code
git clone https://github.com/latin-language-toolkit/llt
cd llt
bundle
gem install llt

# Install warbler
gem install warble

# Build the war
warble

# Deploy the war
curl --upload-file llt.war "http://admin:PASSWORD@http://hostname:8080/manager/deploy?path=/llt&update=true"


