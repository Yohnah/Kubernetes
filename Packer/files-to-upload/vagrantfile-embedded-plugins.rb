#VAGRANT-BEGIN
# Add commands to vagrant cli to manage the kubernetes box. DO NOT MODIFY

class SetupSingleNode < Vagrant.plugin(2, :command)
  def self.synopsis
    "Setup a Kubernetes Single node cluster"
  end
  def execute
    options = {}
    opts = OptionParser.new do |o|
      o.banner = "Usage: vagrant setup-single-node"
      o.separator ""
      o.separator "Options:"
      o.separator ""
    end

    argv = parse_options(opts)
    
    with_target_vms(nil, single_target: true) do |vm|
      env = vm.action(:ssh_run, ssh_run_command: "setup-single-node")
      status = env[:ssh_run_exit_status] || 0
      return status
    end
  end
end

class Plugin < Vagrant.plugin("2")
  name "Setup a Single Kubernetes node"
  description "Setup a Single Kubernete node"
  command "setup-single-node" do
    SetupSingleNode
  end
end

class KubeAdm < Vagrant.plugin(2, :command)
  def self.synopsis
    "kubeadm shortcut to call the installed kubeadm on guest"
  end
  def execute
    opts = OptionParser.new do |o|
      o.banner = "Usage: vagrant kubeadm -- <kubeadm arguments>"
      o.separator ""
      o.separator "Example:"
      o.separator "$ vagrant kubeadm -- init"
      o.separator "      The command \"vagrant kubeadm -- init\" match \"kubeadm init\" on kubeadm standard"
      o.separator ""
      o.separator "Options:"
      o.separator ""
    end

    argv = parse_options(opts)
    return if !argv

    with_target_vms(nil, single_target: true) do |vm|
      env = vm.action(:ssh_run, ssh_run_command: "cd /vagrant; sudo kubeadm #{argv.join(" ")}", tty: true,)
      status = env[:ssh_run_exit_status] || 0
    end

  end
end

class Plugin < Vagrant.plugin("2")
  name "Kubeadm parser"
  description "Kubeadm parser"
  command "kubeadm" do
    KubeAdm
  end
end

class KubeCtl < Vagrant.plugin(2, :command)
  def self.synopsis
    "kubectl shortcut to call the installed kubectl on guest"
  end
  def execute
    opts = OptionParser.new do |o|
      o.banner = "Usage: vagrant kubectl -- <kubectl arguments>"
      o.separator ""
      o.separator "Example:"
      o.separator "$ vagrant kubectl -- get nodes"
      o.separator "      The command \"vagrant kubectl -- get nodes\" match \"kubeadm get nodes\" on kubectl standard"
      o.separator ""
      o.separator "Options:"
      o.separator ""
    end

    argv = parse_options(opts)
    return if !argv

    with_target_vms(nil, single_target: true) do |vm|
      env = vm.action(:ssh_run, ssh_run_command: "sudo chmod o+r /etc/kubernetes/admin.conf; cd /vagrant; KUBECONFIG=/etc/kubernetes/admin.conf kubectl #{argv.join(" ")}", tty: true,)
      status = env[:ssh_run_exit_status] || 0
    end

  end
end

class Plugin < Vagrant.plugin("2")
  name "Kubectl parser"
  description "Kubectl parser"
  command "kubectl" do
    KubeCtl
  end
end

class ShowIPs < Vagrant.plugin(2, :command)
  def self.synopsis
    "Show configured IP addresses and network interfaces on the guest machine"
  end
  def execute
    opts = OptionParser.new do |o|
      o.banner = "Usage: vagrant showIPs"
      o.separator ""
      o.separator "Example:"
      o.separator "$ vagrant showIPs"
      o.separator ""
      o.separator "Options:"
      o.separator ""
    end

    argv = parse_options(opts)
    return if !argv

    with_target_vms(nil, single_target: true) do |vm|
      env = vm.action(:ssh_run, ssh_run_command: "get-ips.sh", tty: false,)
      status = env[:ssh_run_exit_status] || 0
    end

  end
end

class Plugin < Vagrant.plugin("2")
  name "Show IP Addresses"
  description "Show IP Addresses"
  command "show-ips" do
    ShowIPs
  end
end

class DumpKubectlConfig < Vagrant.plugin(2, :command)
  def self.synopsis
    "Dump kubectl config"
  end
  def execute
    opts = OptionParser.new do |o|
      o.banner = "Usage: vagrant kubectl-config"
      o.separator ""
      o.separator "Example:"
      o.separator "$ vagrant showIPs"
      o.separator ""
      o.separator "Options:"
      o.separator ""
    end

    argv = parse_options(opts)
    return if !argv

    with_target_vms(nil, single_target: true) do |vm|
      env = vm.action(:ssh_run, ssh_run_command: "dump-kubectl-config", tty: false,)
      status = env[:ssh_run_exit_status] || 0
    end

  end
end

class Plugin < Vagrant.plugin("2")
  name "Dump kubectl config"
  description "Dump kubectl config"
  command "kubectl-config" do
    DumpKubectlConfig
  end
end

class InstallKubeCTL < Vagrant.plugin(2, :command)
  def self.synopsis
    "Install Kubectl into current vagrant workspace/bin directory"
  end
  def execute
    opts = OptionParser.new do |o|
      o.banner = "Usage: vagrant install-kubectl"
      o.separator ""
      o.separator "Example:"
      o.separator "$ vagrant install-kubectl"
      o.separator ""
      o.separator "Options:"
      o.separator ""
    end

    argv = parse_options(opts)
    return if !argv

    with_target_vms(nil, single_target: true) do |vm|
      env = vm.action(:ssh_run, ssh_run_command: ". /etc/profile; install-kubectl.sh", tty: false,)
      status = env[:ssh_run_exit_status] || 0
    end

  end
end

class Plugin < Vagrant.plugin("2")
  name "Install kubectl"
  description "Install Kubectl into current vagrant workspace/bin directory"
  command "install-kubectl" do
    InstallKubeCTL
  end
end

class DNS < Vagrant.plugin(2, :command)
  def self.synopsis
    "Manage ZeroConf DNS (Avahi)"
  end
  def execute
    opts = OptionParser.new do |o|
      o.banner = "Usage: vagrant dns <options>"
      o.separator ""
      o.separator "Example:"
      o.separator "$ vagrant dns set example.local 127.0.0.1  #The \".local\" suffix is always added if not written"
      o.separator "$ vagrant dns unset example.local"
      o.separator "$ vagrant dns list"
      o.separator ""
      o.separator "Options:"
      o.separator "   set <DNSNAME> <IP Address>  - Create a new ZeroConf DNS record to point the DNSNAME to specific IP Address"
      o.separator "   unset <DNSNAME>             - Remove a created ZeroConf DNS record"
      o.separator "   list                        - List existing ZeroConf DNS records"
    end

    argv = parse_options(opts)
    return if !argv

    with_target_vms(nil, single_target: true) do |vm|
      env = vm.action(:ssh_run, ssh_run_command: "cd /vagrant; sudo /usr/local/bin/dns #{argv.join(" ")}", tty: false,)
      status = env[:ssh_run_exit_status] || 0
    end

  end
end

class Plugin < Vagrant.plugin("2")
  name "ZeroConf DNS"
  description "Manage ZeroConf DNS (Avahi)"
  command "dns" do
    DNS
  end
end
#VAGRANT-END