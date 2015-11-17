# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.ssh.forward_agent = true

  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 3030, host: 3030

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.vm.synced_folder ".", "/dashboard/"

  config.vm.provision :shell do |sh|
    sh.privileged = false
    sh.path = "vagrant/bootstrap.sh"
  end
end
