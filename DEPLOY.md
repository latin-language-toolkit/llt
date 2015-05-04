To deploy as a war under Tomcat:

# Install Prerequisites

ruby (2.0)
Jruby (1.7)
Tomcat 6.x
Postgresql 9.x

    gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable
    source /home/ubuntu/.rvm/scripts/rvm
    rvm install jruby-1.7.16.1
    rvm install ruby-2.0.0-p594
    echo "export JRUBY_OPTS=--2.0" > ~/.bash_profile
    sudo apt-get install postgresql
    sudo apt-get install tomcat6 


# Get the LLT code

git clone https://github.com/latin-language-toolkit/llt
cd llt

rvm use jruby
bundle
gem install llt

# Install warbler

gem install warbler

# Build the war
warble

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

# Deploy the war

(Back in the llt directory)

curl --upload-file llt.war "http://admin:PASSWORD@http://hostname:8080/manager/deploy?path=/llt&update=true"


# Troubleshooting

If you get an error about an invalid multibyte sequence when you deploy the war, you probably didn't have the JRUBY_OPTS set right before building the llt gem and war.  
