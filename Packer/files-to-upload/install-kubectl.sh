#!/bin/bash

mkdir -p /vagrant/bin

case $HOST_OS in
    mac)
        wget -O /vagrant/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
    ;;
    linux)
        wget -O /vagrant/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    ;;
    win)
        wget -O /vagrant/bin/kubectl.exe "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/windows/amd64/kubectl.exe"
    ;;
esac

chmod +x /vagrant/bin/*