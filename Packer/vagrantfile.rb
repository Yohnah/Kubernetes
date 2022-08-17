# -*- mode: ruby -*-
# vi: set ft=ruby :

class VagrantPlugins::ProviderVirtualBox::Action::Network
  def dhcp_server_matches_config?(dhcp_server, config)
    true
  end
end

module OS
  def OS.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
      !OS.windows?
  end

  def OS.linux?
      OS.unix? and not OS.mac?
  end
end

Host_OS = "win"
if OS.windows?
  HostDir = ENV["USERPROFILE"]
  Aux = HostDir.split('\\')
  Aux.shift()
  GuestDir = "/" + Aux.join('/')
  Host_OS = "win"
end

if OS.mac?
  HostDir = ENV["HOME"]
  GuestDir = HostDir
  Host_OS = "mac"
end

if OS.linux?
  HostDir = ENV["HOME"]
  GuestDir = HostDir
  Host_OS = "linux"
end

$msg = <<MSG
Welcome to Kubernetes Linux box for Vagrant by Yohnah
=================================================

Host Operative System detected: #{Host_OS}
Yohnah/Docker was successfully installed on your device

This box has installed and configured all features, modules and tools to setup a kubernetes cluster using <<kubeadm>> command. To know how kubeadm works visit:

  https://kubernetes.io/docs/reference/setup-tools/kubeadm/

Or for further information and other kubeadm setup examples, see: https://github.com/Yohnah-org/Kubernetes

For creating a Kubernetes single node cluster, just run:

  $ vagrant setup-single-node

Or, you can create a kubernetes cluster using kubeadm init (see https://kubernetes.io/docs/reference/setup-tools/kubeadm/) by means of vagrant command as follows:

  $ vagrant kubeadm -- <kubeadm arguments> 

  Ex:

    $ vagrant kubeadm -- init # it is the same as "kubeadm init" standard command

For manage the created kubernetes cluster just use the vagrant cli command:

  $ vagrant kubectl -- <kubectl commands>

  Ex:

    $ vagrant kubectl -- get nodes # it is the same as "kubeadm get nodes" standard command

For dumping the kubectl config, just run:

  $ vagrant kubectl-config > /PATH/config #where PATH is the path where you want to dump the kubectl configuration

  And use it with a installed kubectl on host as follows:

  $ kubectl get nodes --kubeconfig /PATH/config

  or

  $ export KUBECONFIG=/PATH/config
  $ kubectl get nodes

To list the IP addresses running onto guest:

  $ vagrant show-ips

MSG

# Vagrant file definition

Vagrant.configure(2) do |config|
  config.vm.post_up_message = $msg
  config.ssh.shell = '/bin/sh'

  config.vm.synced_folder HostDir, GuestDir
  
  #config.vm.network "forwarded_port", guest: 2375, host: 2375, host_ip: "127.0.0.1", auto_correct: true

  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = 2048
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--uart1", "off"]
    vb.customize ['modifyvm', :id, '--vrde', 'off']
  end

  config.vm.provider "parallels" do |pl, override|
    pl.memory = 2048
    pl.cpus = 2
  end

  config.vm.provider "hyperv" do |hv, override|
    hv.memory = 2048
    hv.cpus = 2
  end

  config.vm.provider "vmware_desktop" do |vm, override|
    vm.memory = 2048
    vm.cpus = 2
  end

  $envvars = <<-EOF
  echo export HOST_OS=\"#{Host_OS}\" | sudo tee /etc/profile.d/envvars.sh
  EOF

  config.vm.provision "shell", inline: $envvars

  $setplugins = <<-EOF
  sed -i '/#VAGRANT-BEGIN/,/#VAGRANT-END/d' /vagrant/Vagrantfile
  cp /vagrant/Vagrantfile /tmp/Vagrantfile.backup
  cat /tmp/Vagrantfile.backup /usr/local/share/vagrantfile-embedded-plugins.rb > /vagrant/Vagrantfile
  EOF

  config.vm.provision "shell", inline: $setplugins, run: "always"

end
