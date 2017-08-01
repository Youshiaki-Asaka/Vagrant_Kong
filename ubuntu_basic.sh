#!/bin/bash
set -x
##---------------------------------------
## apt-get update / upgrade
##---------------------------------------
sudo apt-get update -y

## becuse it will try to install grub and ask input, Need to be done by manual operation
## sudo apt-get upgrade -y

##---------------------------------------
## OS Basci setting 
##---------------------------------------
# Time Zone
# Linux Set Date and Time From a Command Prompt
#   https://www.cyberciti.biz/faq/howto-set-date-time-from-linux-command-prompt/
sudo timedatectl set-timezone 'Asia/Bangkok'
# Check sudo timedatectl

# Locale
# How to Set Locales (i18n) On a Linux or Unix
#  https://www.cyberciti.biz/faq/how-to-set-locales-i18n-on-a-linux-unix/
sudo locale-gen en_US.UTF-8
# Check locale

##---------------------------------------
## Basic tools Install
##---------------------------------------
## File downloader 
sudo apt-get install -y unzip wget curl

## VCS(Version Control System)
sudo apt-get install -y git subversion

## File Manager 
sudo apt-get install -y mc

## Network monitoring
sudo apt-get install -y vnstat iftop nethogs iperf3

## System monitoring
sudo apt-get install -y sysstat dstat

## Install setup utlity
sudo apt-get install -y whois expect
sudo apt-get install -y dos2unix tree

## Install jq
sudo apt-get install -y jq

## Install gdebi  for local debian package  : sudo gdebi /path/to/filename.deb
sudo apt-get install -y gdebi-core

## Install peco
if ! which peco > /dev/null 2>&1 ; then
cd 
  if [ ! -f /vagrant/pkg/peco_linux_amd64.tar.gz ] ; then
    wget -nv https://github.com/peco/peco/releases/download/v0.5.1/peco_linux_amd64.tar.gz
  else
    cp /vagrant/pkg/peco_linux_amd64.tar.gz ./
  fi
  tar xvzf peco_linux_amd64.tar.gz
  sudo cp peco_linux_amd64/peco /usr/bin/peco
  sudo chown root /usr/bin/peco
  rm -f peco_linux_amd64.tar.gz
  rm -f -r peco_linux_amd64
fi

##---------------------------------------
##  Clean Up
##---------------------------------------
## https://askubuntu.com/questions/146921/how-do-i-apt-get-y-dist-upgrade-without-a-grub-config-prompt
## sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
## sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
## sudo apt-get autoclean -y

##---------------------------------------
##  Insatlled informations list
##---------------------------------------
hostnamectl 
lsb_release -a
## apt list --installed
