To deploy as a war under Tomcat:

# Prerequisites

Jruby 

Postgresql

Tomcat 6

# Get LLT Db handler code and install the db
git clone https://github.com/latin-language-toolkit/llt-db_handler

cd llt-db_handler

su - postgres

psql

    create user prometheus with password 'admin'
    alter user prometheus with createdb
    create database prometheus
    \q

N.B. on using the Rake tasks for the DB:

* the rake tasks are for localhost. You will need to update the tasks.rb to change the hostname if you aren't installing on localhost



rake db:prometheus:create -h [hostname]

rake db:prometheus:seed -h [hostname]

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


