#!/bin/bash
set -x

##----------------------------------------------------------------------
##  User Name and Db Name to be used
##----------------------------------------------------------------------
USER="kong"
DB="kong"
PWD="p@ssw0rd"

##----------------------------------------------------------------------
##  To ensure the following was already setted
##----------------------------------------------------------------------
# Time Zone
## sudo timedatectl set-timezone 'Asia/Bangkok'
# Locale
## sudo locale-gen en_US.UTF-8

##-----------------------------------------------------------------------
## Step01 : Install PostgreSQL
## Step02 : Start PostgreSQL
##-----------------------------------------------------------------------
## How To Install and Use PostgreSQL on Ubuntu 16.04 
##   https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-16-04
## PostgreSQL - Community Help Wiki
##   https://help.ubuntu.com/community/PostgreSQL
## If you want to install v9.6,
## PostgreSQL Apt Repository
##   https://www.postgresql.org/download/linux/ubuntu/

sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
wget -nv -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y postgresql-9.6

## apt list -y postgresql*     # Check available package
## su - postgres               # login as postgres
## sudo -u postgres -i         # login as postgres

## Important Folders and Files
##  Prog  : /usr/share/postgresql/9.6
##  Data  : /var/lib/postgresql/9.6
##  Log   : /var/log/postgresql/
##  Conf  : /etc/postgresql/9.6/main
##          /etc/postgresql/9.6/main/pg_hba.conf
##          /etc/postgresql/9.6/main/postgresql.conf
##  whereis  postgresql
##   postgresql: /usr/lib/postgresql /etc/postgresql /usr/share/postgresql

##-----------------------------------------------------------------------
## Step03 : Check & Edit Configuration
##-----------------------------------------------------------------------
## How To Secure PostgreSQL Against Automated Attacks 
##   https://www.digitalocean.com/community/tutorials/how-to-secure-postgresql-against-automated-attacks
##   https://www.postgresql.org/docs/9.5/static/auth-pg-hba-conf.html

## Backup Configulation files
sudo cp /etc/postgresql/9.6/main/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf.org
sudo cp /etc/postgresql/9.6/main/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf.org

## You should configure "pg_hba.conf"
## https://www.digitalocean.com/community/tutorials/how-to-secure-postgresql-against-automated-attacks
## DataBase Authentification setting
##    Configure  $ sudo vi /etc/postgresql/9.6/main/pg_hba.conf
##      Chainge "peer" to "md5"
##  -----------------------------------------------------------------------
##    # Database administrative login by Unix domain socket
##    local   all             postgres                                peer
##    # TYPE  DATABASE        USER            ADDRESS                 METHOD
##    # "local" is for Unix domain socket connections only
##    local   all             all                                     md5  <== from peer
##    # IPv4 local connections:
##    host    all             all             127.0.0.1/32            md5
##    # IPv6 local connections:
##    host    all             all             ::1/128                 md5
##  -----------------------------------------------------------------------
## TYPE
##  "host" is either a plain or SSL-encrypted TCP/IP socket
##  "hostssl" is an SSL-encrypted TCP/IP socket
## Allow users from 192.168.x.x hosts to connect to any database
##  host  all  all  192.168.0.0/16  md5
## Allow users from 192.168.1.x hosts to connect to any database
##  host  all  all  192.168.1.0/24  md5

if ! sudo cat /etc/postgresql/9.6/main/pg_hba.conf | grep -q 'Added by Apl' ; then
  # Serch key word:"local   all" and replace from "peer" to "md5"
  sudo sed -i -e '/local   all             all/s/peer/md5/'  /etc/postgresql/9.6/main/pg_hba.conf
  # Added by Apl As the sample, Need to adjust 
  sudo sed -i -e '$a\# Added by Apl As the sample, Need to adjust' /etc/postgresql/9.6/main/pg_hba.conf
  sudo sed -i -e "\$a\host  ${DB}  ${USER}  192.168.0.0/16  md5" /etc/postgresql/9.6/main/pg_hba.conf
  sudo sed -i -e "\$a\host  all    postgres 192.168.0.0/16  md5" /etc/postgresql/9.6/main/pg_hba.conf
fi

## Allow DataBase Access via Network setting
## Configure  $ sudo vi /etc/postgresql/9.6/main/postgresql.conf
## make it the followings.
##  #listen_addresses = 'localhost' ==> listen_addresses = '*'
## ---------------------------------------------------------------------
##    # - Connection Settings -
##    listen_addresses = '*'                  # what IP address(es) to listen on;
##    port = 5432                             # (change requires restart)
## ---------------------------------------------------------------------
## Allow DataBase Access via Network setting
# find & replace from "#listen_addresses = 'localhost'" to "listen_addresses = '*'"  It iclude Single quotation ' (x27)
sudo sed -i -e 's/#listen_addresses = \x27localhost\x27/listen_addresses = \x27*\x27/'  /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#port = 5432/port = 5432/'  /etc/postgresql/9.6/main/postgresql.conf

## TimeZone Change from UTC to Asia/Bangkok
## sudo sed -i -e 's/log_timezone = \x27UTC\x27/log_timezone = \x27Asia\/Bangkok\x27/'  /etc/postgresql/9.6/main/postgresql.conf

# ==================================================================
## password settting  for postgres
# ==================================================================
## OS level Password setting
## $ sudo passwd postgres
## Enter new UNIX password:
## Retype new UNIX password:
## passwd: password updated successfully
PGPASSWORD=${PWD}
expect -c "
set timeout 5
spawn sudo passwd postgres
expect \"Enter new UNIX password:\"
send   \"${PGPASSWORD}\n\"
expect \"Retype new UNIX password:\"
send   \"${PGPASSWORD}\n\"
expect \"$\"
exit 0
"

## Postgresql DataBase User Password
## sudo -u postgres psql
## postgres=# alter role postgres with password 'p@ssw0rd' ;
## postgres=#\q
sudo -u postgres psql << EOF
alter role postgres with password '${PGPASSWORD}' ;
\q
EOF

## ReStart PostgreSQL
sudo systemctl restart postgresql-9.6 

## verification   Status should be  "Active: active (exited)"
sudo lsof -i -nP | grep postgres
systemctl status --no-pager postgresql-9.6 
sudo tail -n10 /var/log/postgresql/postgresql-9.6-main.log

# ==================================================================
## Step04( To make Much Secure ) :  Create User
# ==================================================================
##  this  will ask Password for dmslight user on PostgreSQL
## $ sudo -E -u postgres createuser -P -e -S --login dmslight
## Enter password for new role:
## Enter it again:
## CREATE ROLE dmslight PASSWORD 'md5173dd4fa13bf2e34d9340b9324d02c00' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;

PGPASSWORD=${PWD}
expect -c "
set timeout 5
spawn sudo -E -u postgres createuser -P -e -S --login ${USER}
expect \"Enter password for new role:\"
send   \"${PGPASSWORD}\n\"
expect \"Enter it again:\"
send   \"${PGPASSWORD}\n\"
expect \"$\"
exit 0
"

## Verification
sudo -u postgres psql << EOF
SELECT version();
\du
\q
EOF

## sudo -u postgres psql << EOF
## CREATE USER dmslight WITH PASSWORD 'p@ssw0rd';
## \q
## EOF

##-----------------------------------------------------------------------
## Step05 : DB Creation
##-----------------------------------------------------------------------
## Create DB
## sudo -u postgres createdb -U postgres -e --owner=dmslight --encoding=UTF8 dmslight
sudo -u postgres createdb --owner=${USER} --encoding=UTF8  ${DB} 

## Verification
sudo -u postgres psql << EOF
SELECT version();
\l
\c ${DB}
\dt+
\q
EOF

export PGPASSWORD=${PWD}
psql -d ${DB} -U postgres -h '127.0.0.1' << EOF
\du
\q
EOF

psql -d ${DB} -U ${USER} -h '127.0.0.1' << EOF
\du
\c ${DB}
\dt+
\q
EOF

## sudo -u postgres psql << EOF
## CREATE DATABASE dmslight WITH ENCODING='UTF-8';
## GRANT ALL ON DATABASE dmslight TO dmslight;
## \q
## EOF

##  From pgAdmin 
##  General Tab
##    Name               : CentOS         <== Input
##  Connection Tab
##    Host name/address  : 192.168.33.10  <== Input
##    Port               : 5432           <== Default
##    Maintenance database : postgres     <== Default
##    User name          : postgres       <== Default
##    Password           : p@ssw0rd       <== Input
##    Role               :                <== No Change
##    SSL Mode           : Prefer         <== No Change

# ==================================================================
## Step06( Much good for maintenance) : Configure configuration files.
# ==================================================================
##  1. Configuration for Logging format and rotation ( Every week ,Keep only 7days )
##     File is located at  sudo vi /etc/postgresql/9.6/main/postgresql.conf
##     Find "ERROR REPORTING AND LOGGING" section and change these lines:
##      #log_destination = 'stderr'
##      #logging_collector = off
##      #log_directory = 'pg_log'
##      #log_file_mode = 0600
##      #log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
##      #log_truncate_on_rotation = off
##      log_line_prefix = '%t [%p-%l] %q%u@%d '     # special values:
##      #log_min_duration_statement = -1  # -1 is disabled, 0 logs all statements
##     Change to be
##      log_destination = 'stderr'
##      logging_collector = on
##      log_directory = '/var/log/postgresql'
##      log_file_mode = 0640
##      log_filename = 'postgresql-%a.log'   # Log rotate every week.
##      log_truncate_on_rotation = on
##      log_line_prefix = '[%t]%u %d %p[%l] ' # Log %t=timestamp  %u=UserName %d=DatabaseName %p PID and %l=Session
##      log_min_duration_statement = 30000    # Slow Query Over 30 Sec SQL will record
## Using sed, need many escape for single quotaion \x27 , other case \[  \] \%
sudo sed -i -e 's/#log_destination = \x27stderr\x27/log_destination = \x27stderr\x27/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#logging_collector = off/logging_collector = on/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#log_directory = \x27pg_log\x27/log_directory = \x27\/var\/log\/postgresql\x27/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#log_file_mode = 0600/log_file_mode = 0640/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#log_filename = \x27postgresql-\%Y-\%m-\%d_\%H\%M\%S.log\x27/log_filename = \x27postgresql-\%a.log\x27/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#log_truncate_on_rotation = off/log_truncate_on_rotation = on/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/log_line_prefix = \x27\%t \[\%p-\%l\] \%q\%u@\%d \x27/log_line_prefix = \x27\[\%t\]\%u \%d \%p\[\%l\] \x27/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#log_min_duration_statement = -1/log_min_duration_statement = 30000/' /etc/postgresql/9.6/main/postgresql.conf

## Atudit Log
## From
##   #log_connections = off
##   #log_statement = 'none'
## To 
##   log_connections = on
##   log_statement = 'mod'
sudo sed -i -e 's/#log_connections = off/log_connections = on/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#log_statement = \x27none\x27/log_statement = \x27mod\x27/' /etc/postgresql/9.6/main/postgresql.conf

## ReStart PostgreSQL
sudo systemctl restart postgresql-9.6 

## Verification
cd /var/log/postgresql
ls -al
sudo tail -n10 /var/log/postgresql/postgresql*.log

# ==================================================================
## Step07( Much good for performance) : Configure configuration files : /etc/postgresql/9.6/main/postgresql.conf
# ==================================================================
## PgTune - Tuning PostgreSQL config by your hardware
##   http://pgtune.leopard.in.ua/
##   PGTune calculate configuration for PostgreSQL based on the maximum performance for a given hardware configuration.
## Optimise PostgreSQL for fast testing
##   http://stackoverflow.com/questions/9407442/optimise-postgresql-for-fast-testing
## Tuning Your PostgreSQL Server
##   https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server

##  1. Memory tuning
##    Simply evaluate the proper parameter, we will the following site.
##    PgTune - Tuning PostgreSQL config by your hardware
##      http://pgtune.leopard.in.ua/
##    In case
##      DB Version : 9.5
##      OS Type : Linux/OS X
##      DB Type : Web applications
##      Total Memory(RAM) : 1GB
##      Number of Connection : 10
##    It will show the starting point of tuning parameter.
##      max_connections = 10
##      shared_buffers = 256MB         # 25%(15%-30%) of total available RAM
##      effective_cache_size = 768MB   # 50% of total available RAM
##      work_mem = 26214kB             # query performance faster with in-memory sort
##      maintenance_work_mem = 64MB
##      min_wal_size = 1GB
##      max_wal_size = 2GB
##      checkpoint_completion_target = 0.7
##      wal_buffers = 7864kB
##      default_statistics_target = 100
##  The following is original setting Values
##      max_connections = 100                   # (change requires restart)
##      shared_buffers = 128MB                  # min 128kB
##      #effective_cache_size = 4GB
##      #work_mem = 4MB                         # min 64kB
##      #maintenance_work_mem = 64MB            # min 1MB
##      #min_wal_size = 80MB
##      #max_wal_size = 1GB
##      #checkpoint_completion_target = 0.5     # checkpoint target duration, 0.0 - 1.0
##      #wal_buffers = -1                       # min 32kB, -1 sets based on shared_buffers
##      #default_statistics_target = 100        # range 1-10000
## sudo vi /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/max_connections = 100/max_connections = 50/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/shared_buffers = 128MB/shared_buffers = 128MB/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#effective_cache_size = 4GB/effective_cache_size = 256MB/' /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e 's/#work_mem = 4MB/work_mem = 24MB/' /etc/postgresql/9.6/main/postgresql.conf
## sudo sed -i -e 's/#maintenance_work_mem = 64MB/maintenance_work_mem = 64MB/' /etc/postgresql/9.6/main/postgresql.conf
## sudo sed -i -e 's/#min_wal_size = 80MB/min_wal_size = 1GB/' /etc/postgresql/9.6/main/postgresql.conf
## sudo sed -i -e 's/#max_wal_size = 1GB/max_wal_size = 2GB/' /etc/postgresql/9.6/main/postgresql.conf
## sudo sed -i -e 's/#checkpoint_completion_target = 0.5/checkpoint_completion_target = 0.7/' /etc/postgresql/9.6/main/postgresql.conf
## sudo sed -i -e 's/#wal_buffers = -1/wal_buffers = 7864kB/' /etc/postgresql/9.6/main/postgresql.conf
## sudo sed -i -e 's/#default_statistics_target = 100/default_statistics_target = 100/' /etc/postgresql/9.6/main/postgresql.conf

## ReStart PostgreSQL
sudo systemctl restart postgresql-9.6 

## Verification
sudo lsof -i -nP | grep postgres
systemctl status --no-pager postgresql-9.6 
sudo tail -n10 /var/log/postgresql/postgresql*.log
## sudo tail -n10 -f /var/log/postgresql/postgresql-Sat.log
