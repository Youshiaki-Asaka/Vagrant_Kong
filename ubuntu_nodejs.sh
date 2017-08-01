#!/bin/bash
set -x

##--------------------------------------------------------------------------
## Installing Node.js via package manager : Debian and Ubuntu based Linux distributions
## https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
## -------------------------------------------------------------------------

## sudo apt-get purge -y --auto-remove nodejs nodejs-legacy npm

sudo curl -sS -L https://deb.nodesource.com/setup_6.x | sudo sudo bash -
sudo apt-get install -y nodejs

## sudo apt-get install -y build-essential

## Verification
node -v                    # v6.10.2
npm -v                     # 3.10.10

## npm update
sudo npm update -g npm
npm -v                     # 4.5.0

## jshint Install 
sudo npm install -g jshint

##--------------------------------------------------------------------------
## If you want manage several version, you can use "n"
##   https://tecadmin.net/upgrade-nodejs-via-npm/
##   https://github.com/tj/n
## -------------------------------------------------------------------------
## sudo npm cache clean
## sudo npm install n -g
## sudo n lts
## sudo ln -sf /usr/local/bin/node /usr/bin/node
## node -v
## npm -v
