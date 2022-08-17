BOXFILE=$(cat /tmp/packer-build/1.24.3/manifest.json | jq '.builds[].files[].name' | sed 's/"//g')
vagrant box remove Kubernetes-$CURRENT_KUBERNETES_VERSION-box