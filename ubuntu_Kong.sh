#!/bin/bash
set -x

##------------------------------------------------------------------------------------
## Kong OverView
##------------------------------------------------------------------------------------
## Home Page & Overview
##   https://getkong.org/
##   https://github.com/Mashape/kong
##   Kong is a scalable, open source API Layer (also known as an API Gateway, or API Middleware).
##   Backed by the battle-tested NGINX with a focus on high performance,
##     Kong was made available as an open-source platform in 2015.
## What is an API Gateway?
##  Put simply, an API gateway is a filter that sits in front of your RESTful API. This gateway can be hosted by you or a third party. Typically, the gateway will provide one or more of the following:
##    Access control- only allow authenticated and authorized traffic
##    Rate limiting - restrict how much traffic is sent to your API
##    Analytics, metrics and logging – track how your API is used
##    Security filtering – make sure the incoming traffic is not an attack
##    Redirection – send traffic to a different endpoint
## Plugins: Expendable architecture for adding functionality to Kong and APIs.
##    Authentication: Manage consumer credentials query string and header tokens.
##    ACL     : Acccess Control for your API Consumers.
##    OAuth2.0: Add easily an OAuth2.0 authentication to your APIs.
##    JWT     : Verify and authenticate JSON Web Tokens.
##    Logging : Log requests and responses to your system over HTTP, TCP, UDP or to disk.
##
## Software requirements:
## OS      : Ubuntu 16.04
## DB      : PostgreSQL9.6.3     via apt-get from PostgreSQL Apt Repository
## WEB     : Kong0.10.3 (= OpenResty + NGINX )
##
## Youtube : Microservices & API Gateways | Mashape 
##   https://www.youtube.com/watch?v=zs_QyRTIpDM
## Microservices & API Gateways, Part 1: Why an API Gateway?
##   https://www.nginx.com/blog/microservices-api-gateways-part-1-why-an-api-gateway/
## Microservices & API Gateways, Part 2: How Kong Can Help
##   https://www.nginx.com/blog/microservices-api-gateways-part-2-how-kong-can-help/

##====================================================================================
##  Kong Ubuntu Installation
##    https://getkong.org/install/centos/
##------------------------------------------------------------------------------------
## Step 1 :  Group/User and PostgreSQL Install & Setup
##------------------------------------------------------------------------------------
## ubuntu_basic.sh
## ubuntu_nodejs.sh
## ubuntu_postgresql96.sh  with USER="kong" / DB="kong" / PWD="p@ssw0rd"
##                         CREATE USER kong; CREATE DATABASE kong OWNER kong;
## psotgresql running Check
sudo lsof -i -nP | grep postgres
systemctl status --no-pager postgresql 

# ==================================================================
## Add kong Group & User
# ==================================================================
if ! cat /etc/passwd | grep -q 'kong' ; then
  sudo groupadd kong
  sudo adduser --system --shell /bin/bash --ingroup kong kong
fi

##------------------------------------------------------------------------------------
## Step 2 : Install Dependencies
##------------------------------------------------------------------------------------
sudo apt-get install -y openssl libpcre3 procps perl

##------------------------------------------------------------------------------------
## Step 3 : Install Kong
##------------------------------------------------------------------------------------
if [ ! -f /vagrant/pkg/kong-0.10.3.xenial_all.deb ] ; then
  wget -nv https://github.com/Mashape/kong/releases/download/0.10.3/kong-0.10.3.xenial_all.deb
else
  cp /vagrant/pkg/kong-0.10.3.xenial_all.deb ./
fi
sudo dpkg -i kong-0.10.3.*.deb

## Configure PostgreSQl setting on Kong  ( Need to use Password )
sudo cp -p /etc/kong/kong.conf.default /etc/kong/kong.conf
sudo sed -i -e 's/#database = postgres/database = postgres/'  /etc/kong/kong.conf
sudo sed -i -e 's/#pg_host = 127.0.0.1/pg_host = 127.0.0.1/'  /etc/kong/kong.conf
sudo sed -i -e 's/#pg_port = 5432/pg_port = 5432/'  /etc/kong/kong.conf
sudo sed -i -e 's/#pg_user = kong/pg_user = kong/'  /etc/kong/kong.conf
sudo sed -i -e 's/#pg_password =      /pg_password = p@ssw0rd/'  /etc/kong/kong.conf
sudo sed -i -e 's/#pg_database = kong/pg_database = kong/'  /etc/kong/kong.conf

# To enforce Group&User setting 
sudo chown -R ${USER}:${USER} /usr/local/kong
sudo chown -R ${USER}:${USER} /etc/kong

## Start kong   , If you counter error , to use kong start --vv
kong start

# Kong Running Check
curl -sS 127.0.0.1:8001 | jq '.'

##  Now You can use Kong
## :8001 on which the Admin API used to configure Kong listens.
## :8000 on which Kong listens for incoming HTTP traffic from your clients, and forwards it to your upstream services.
## :8444 on which the Admin API listens for HTTPS traffic.
## :8443 on which Kong listens for incoming HTTPS traffic. This port has a similar behavior as the :8000 port, except that it expects HTTPS traffic only. This port can be disabled via the configuration file.
## http://localhost:8001     On Vagrant http://192.168.33.10:8001   http://localhost:8001
## http://localhost:8000     On Vagrant http://192.168.33.10:8000   http://localhost:8000
## http://localhost:8444     On Vagrant http://192.168.33.10:8444   http://localhost:8444
## http://localhost:8443     On Vagrant http://192.168.33.10:8443   http://localhost:8443

##------------------------------------------------------------------------------------
## Step 4 : Configuration
##------------------------------------------------------------------------------------
## sudo cp -p /etc/kong/kong.conf.default /etc/kong/kong.conf
## sudo vi /etc/kong/kong.conf
##
## --- Datastore section -------------------------------------------- 
##   https://getkong.org/docs/0.10.x/configuration/#datastore-section
## To setup PostgreSQL Access 
##  database = postgres             # Determines which of PostgreSQL or Cassandra
##  pg_host = 127.0.0.1             # The PostgreSQL host to connect to.
##  pg_port = 5432                  # The port to connect to.
##  pg_user = kong                  # The username to authenticate if required.
##  pg_password = kong              # The password to authenticate if required.
##  pg_database = kong              # The database name to connect to.
## sudo sed -i -e 's/#database = postgres/database = postgres/'  /etc/kong/kong.conf
## sudo sed -i -e 's/#pg_host = 127.0.0.1/pg_host = 127.0.0.1/'  /etc/kong/kong.conf
## sudo sed -i -e 's/#pg_port = 5432/pg_port = 5432/'  /etc/kong/kong.conf
## sudo sed -i -e 's/#pg_user = kong/pg_user = kong/'  /etc/kong/kong.conf
## sudo sed -i -e 's/#pg_password =      /pg_password = p@ssw0rd/'  /etc/kong/kong.conf
## sudo sed -i -e 's/#pg_database = kong/pg_database = kong/'  /etc/kong/kong.conf
##
## --- Nginx section-------------------------------------------------- 
##   https://getkong.org/docs/0.10.x/configuration/#nginx-section
## To change kong defaut port to be original port for HTTP and HTTPS
##  #proxy_listen = 0.0.0.0:8000      => proxy_listen = 0.0.0.0:80
##  #proxy_listen_ssl = 0.0.0.0:8443  => proxy_listen_ssl = 0.0.0.0:443
## sudo sed -i -e 's/#proxy_listen = 0.0.0.0:8000/#proxy_listen = 0.0.0.0:80/'  /etc/kong/kong.conf
## sudo sed -i -e 's/#proxy_listen_ssl = 0.0.0.0:8443/#proxy_listen_ssl = 0.0.0.0:443/'  /etc/kong/kong.conf
##
## To setup formal SSL(TSL) certification
##  #ssl_cert =
##  #ssl_cert_key =
##  #admin_ssl_cert =
##  #admin_ssl_cert_key =
##
##-----------------------------------------------------------------
## How To Create a Self-Signed SSL Certificate for Nginx in Ubuntu 16.04
##  https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04
## Create /etc/ssl/private/selfsigned.key and  /etc/ssl/certs/selfsigned.crt
## sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt
  # This will ask
  #  Country Name (2 letter code) [AU]:                          ( TH )
  #  State or Province Name (full name) [Some-State]:            ( Bangkok    )
  #  Locality Name (eg, city) []:                                ( Klongtoey  )
  #  Organization Name (eg, company) [Internet Widgits Pty Ltd]: ( FTH )
  #  Organizational Unit Name (eg, section) []:Development Dept  ( AMBG )
  #  Common Name (e.g. server FQDN or YOUR name) []:www.yourdomain.net (192.168.104.236)
  #  Email Address []:yourmail@yourdomain.net                    ( yourmail@yourdomain.net)
cd
expect -c "
set timeout 5
spawn  sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt
expect \"Country Name\"
send   \"TH\n\"
expect \"State or Province Name\"
send   \"Bangkok\n\"
expect \"Locality Name\"
send   \"Klongtoey\n\"
expect \"Organization Name\"
send   \"FTH\n\"
expect \"Organizational Unit Name\"
send   \"AMBG\n\"
expect \"Common Name\"
send   \"192.168.33.10\n\"
expect \"Email Address\"
send   \"yourmail@yourdomain.net\n\"
expect \"$\"
exit 0
"
# Create a strong Diffie-Hellman group, which is used in negotiating Perfect Forward Secrecy with clients.
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 > /dev/null 2>&1

## Logging Files
##  Default will be /usr/local/kong/logs  
##  ├── access.log
##  │   ├── admin_access.log
##  │   ├── error.log
##  │   └── serf.log
##  #proxy_access_log = logs/access.log 
##  #proxy_error_log = logs/error.log 
##  #admin_access_log = logs/admin_access.log 
##  #admin_error_log = logs/error.log
   
## kong reload

##====================================================================================
## Step 5 : Sample Operation
##====================================================================================
## :8001 on which the Admin API used to configure Kong listens.
## :8000 on which Kong listens for incoming HTTP traffic from your clients, and forwards it to your upstream services.
##------------------------------------------------
## Sample Operation : Web Service
##------------------------------------------------
curl -i -XPOST \
  --url http://localhost:8001/apis \
  --data 'name=httpbin' \
  --data 'upstream_url=http://httpbin.org/ip' \
  --data 'uris=/httpbin'

## Registration check
curl -sS -XGET --url http://localhost:8001/apis
## For JSON formatting, you can use jq or python json.tool
curl -sS --url http://localhost:8001/apis | jq '.'
curl -sS --url http://localhost:8001/apis | python -m json.tool

sleep 5
## Access API
curl -i -XGET --url http://localhost:8000/httpbin
curl -sS -XGET http://localhost:8000/httpbin | jq '.'

## Delete API
curl -i -XDELETE --url http://localhost:8001/apis/httpbin

## ----------------------------------------------------------------------
## One more Sample OpenWeatherMap API
## https://dev9.com/blog-posts/2016/6/introduction-to-kong-api-gateway
curl -i -X POST \
--url http://localhost:8001/apis/ \
--data 'name=openweathermap' \
--data 'upstream_url=http://api.openweathermap.org/data/2.5' \
--data 'hosts=api.openweathermap.org' \
--data 'uris=/openweathermap'

## Registration check
curl -sS --url http://localhost:8001/apis | jq '.'

## After regist your account and getting APLID from https://openweathermap.org/api,
## You can get API result like the followings
curl -sS --url 'http://localhost:8000/openweathermap/weather?q=London&APPID=4d4d75fdb0947de3d6d2a4e7357d5415' \
--header 'Host: api.openweathermap.org' | jq '.'

## Add Key-Auth
curl -X POST \
  --url http://localhost:8001/apis/openweathermap/plugins/ \
  --data 'name=key-auth'
  
## Create a Consumer(User)
curl -XPOST \
 --url http://localhost:8001/consumers/ \
 --data "username=Jason"
## Create an API Key , You can set any key
curl -XPOST \
  --url http://localhost:8001/consumers/Jason/key-auth/ \
  --data 'key=ENTER_KEY_HERE'
  ## if you set "--data '' ", Kong will generate key
sleep 5

## Get Result using Key Authentification
curl -sS --url 'http://localhost:8000/openweathermap/weather?q=London&APPID=4d4d75fdb0947de3d6d2a4e7357d5415' \
--header 'Host: api.openweathermap.org' \
--header 'apikey:ENTER_KEY_HERE'  | jq '.'

## Delete API
curl -i -XDELETE --url http://localhost:8001/apis/openweathermap

##------------------------------------------------
## :8444 on which the Admin API listens for HTTPS traffic.
## :8443 on which Kong listens for incoming HTTPS traffic. This port has a similar behavior as the :8000 port, except that it expects HTTPS traffic only. This port can be disabled via the configuration file.
##------------------------------------------------
curl -i -k -XPOST \
  --url https://localhost:8444/apis \
  --data 'name=httpbin' \
  --data 'upstream_url=http://httpbin.org/ip' \
  --data 'uris=/httpbin'
sleep 5
## Check current registered API
curl -sS -k -XGET --url https://localhost:8444/apis | jq '.'
## Get API result
curl -sS -k -XGET https://localhost:8443/httpbin | jq '.'
## Delete
curl -i -k -XDELETE --url https://localhost:8444/apis/httpbin

# ==================================================================
## Step06 : start kong by systemd 
# ==================================================================
# Systemd setting file
# sudo vi /etc/systemd/system/kong.service
# Systemd unit file for kong
kong stop
cd
rm -f kong.service
cat > kong.service << EOF
[Unit]
Description=Kong API Gateway
After=syslog.target network.target postgresql.service

[Service]
Group=kong
User=kong
Type=oneshot
RemainAfterExit=yes

ExecStart=/usr/local/bin/kong start
ExecStop=/usr/local/bin/kong stop
ExecReload=/usr/local/bin/kong reload

[Install]
WantedBy=multi-user.target
EOF
sudo cp kong.service /etc/systemd/system/kong.service
sudo chown -R kong:kong /usr/local/kong
sudo chown -R kong:kong /etc/kong

sudo systemctl daemon-reload
sudo systemctl enable kong.service
sudo systemctl start kong

# Verification
sudo lsof -i -nP | grep kong
sudo systemctl status --no-pager kong

# ==================================================================
## Step07 (Option) : Kong Dashboard
# ==================================================================
## https://github.com/PGBI/kong-dashboard
## Kong dashboard is a UI tool that will let you manage your Kong Gateway setup.
## This Dashboard will let you interact with your Kong API to create or edit APIs, Consumers and Plugins. 

# Install Kong Dashboard
sudo npm install -g kong-dashboard@v2

# Start Kong Dashboard   : To stop, CTRL+C
kong-dashboard start

# You can now browse your kong dashboard at
# http://localhost:8080 on vagrant http://192.168.33.10:8080
# When first vist, input Kong Node URL ==> http://192.168.33.10:8001

# To start Kong Dashboard on a custom port
#   kong-dashboard start -p [port]

