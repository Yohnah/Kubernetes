#!/bin/bash -x

cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

#Disabling swap because of Kubernetes does not support it
sudo sed -i '/swap/d' /etc/fstab

sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system
sudo swapoff -a

sudo apt-get -y install chrony

# requirements for containerd install

sudo apt install -y curl gpg lsb-release apparmor apparmor-utils
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# install containerd

sudo apt update
sudo apt-get install -y containerd.io
sudo mkdir -p /etc/containerd

containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/g' | sudo tee /etc/containerd/config.toml

# requirements for kubernetes install

sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

echo "Installing Kubernetes version $VERSION"

# install kubernetes tools
KUBERNETES_VERSION=$(apt-cache madison kubeadm | grep -i "$VERSION" | awk -F"|" '{ print $2 }' | sed 's/ //g' | uniq | head -n 1)
sudo apt-get install -y kubelet=$KUBERNETES_VERSION kubeadm=$KUBERNETES_VERSION kubectl=$KUBERNETES_VERSION


sudo mv /tmp/setup-single-node /usr/local/bin
sudo chmod +x /usr/local/bin/setup-single-node

sudo mv /tmp/dump-kubectl-config /usr/local/bin
sudo chmod +x /usr/local/bin/dump-kubectl-config

sudo mv /tmp/vagrantfile-embedded-plugins.rb /usr/local/share
sudo chmod +r /usr/local/share/vagrantfile-embedded-plugins.rb

sudo mv /tmp/install-kubectl.sh /usr/local/bin
sudo chmod +x /usr/local/bin/install-kubectl.sh

echo "export KUBECONFIG=/etc/kubernetes/admin.conf" | sudo tee /etc/profile.d/kubectl-config.sh