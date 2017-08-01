<<<<<<< HEAD
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  # https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.box_version = "2.3.7"
  
  # Disable automatic box update checking.
  # config.vm.box_check_update = true
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. 
  # For Kong 
  config.vm.network :forwarded_port, guest: 8000, host: 8000
  config.vm.network :forwarded_port, guest: 8001, host: 8001
  config.vm.network :forwarded_port, guest: 8443, host: 8443
  config.vm.network :forwarded_port, guest: 8444, host: 8444
  # For Kong Dashboard
  config.vm.network :forwarded_port, guest: 8080, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
    # Set the name for the VM
    vb.name = "ubuntu16.04_Kong" 
    # Customize the amount of cpu on the VM:
    # vb.cpus = "4"
    # Customize the amount of memory on the VM:
    vb.memory = "1536"
  end
  # config.vm.hostname = "Kong"
  
  # Proxy Configuration Plugin for Vagrant
  # https://github.com/tmatilai/vagrant-proxyconf
  # A Vagrant plugin that configures the virtual machine to use specified proxies. 
  # if Vagrant.has_plugin?("vagrant-proxyconf")
    # config.proxy.http      = "http://10.164.197.15:8080"
    # config.proxy.https     = "http://10.164.197.15:8080"
    # config.proxy.no_proxy  = "localhost,127.0.0.1"
    # config.git_proxy.http  = "http://10.164.197.15:8080/"
    # config.svn_proxy.http  = "http://10.164.197.15:8080/"
    # config.apt_proxy.http  = "http://10.164.197.15:8080/"
    # config.apt_proxy.https = "http://10.164.197.15:8080/"
  # end
    
  # Enable provisioning with a shell script.
  config.vm.provision :shell, :path => "ubuntu_basic.sh"
  config.vm.provision :shell, :path => "ubuntu_postgresql96.sh"
  config.vm.provision :shell, :path => "ubuntu_nodejs.sh"
  # config.vm.provision :shell, :path => "ubuntu_Kong.sh"
 
  config.vm.provision "shell", inline: <<-UBUNTU_BASIC
    set -x
    apt-get update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
    apt-get autoremove -y
    apt-get autoclean -y
  UBUNTU_BASIC
end
=======
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  # https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.box_version = "2.3.7"
  
  # Disable automatic box update checking.
  # config.vm.box_check_update = true
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. 
  # For Kong 
  config.vm.network :forwarded_port, guest: 8000, host: 8000
  config.vm.network :forwarded_port, guest: 8001, host: 8001
  config.vm.network :forwarded_port, guest: 8443, host: 8443
  config.vm.network :forwarded_port, guest: 8444, host: 8444
  # For Kong Dashboard
  config.vm.network :forwarded_port, guest: 8080, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
    # Set the name for the VM
    vb.name = "ubuntu16.04_Kong" 
    # Customize the amount of cpu on the VM:
    # vb.cpus = "4"
    # Customize the amount of memory on the VM:
    vb.memory = "1536"
  end
  # config.vm.hostname = "Kong"
  
  # Proxy Configuration Plugin for Vagrant
  # https://github.com/tmatilai/vagrant-proxyconf
  # A Vagrant plugin that configures the virtual machine to use specified proxies. 
  # if Vagrant.has_plugin?("vagrant-proxyconf")
    # config.proxy.http      = "http://10.164.197.15:8080"
    # config.proxy.https     = "http://10.164.197.15:8080"
    # config.proxy.no_proxy  = "localhost,127.0.0.1"
    # config.git_proxy.http  = "http://10.164.197.15:8080/"
    # config.svn_proxy.http  = "http://10.164.197.15:8080/"
    # config.apt_proxy.http  = "http://10.164.197.15:8080/"
    # config.apt_proxy.https = "http://10.164.197.15:8080/"
  # end
    
  # Enable provisioning with a shell script.
  config.vm.provision :shell, :path => "ubuntu_basic.sh"
  config.vm.provision :shell, :path => "ubuntu_postgresql96.sh"
  config.vm.provision :shell, :path => "ubuntu_nodejs.sh"
  # config.vm.provision :shell, :path => "ubuntu_Kong.sh"
 
  config.vm.provision "shell", inline: <<-UBUNTU_BASIC
    set -x
    apt-get update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
    apt-get autoremove -y
    apt-get autoclean -y
  UBUNTU_BASIC
end
>>>>>>> origin/master
