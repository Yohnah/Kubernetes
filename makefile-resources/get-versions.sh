#!/bin/bash

case $TYPE in
    current_kubernetes_version)
        curl -sS https://kubernetes.io/releases/ | grep -i "latest release" | grep -oE '([0-9]+)\.([0-9]+)\.([0-9]+)' | head -n 1 | sed 's/ //g'
    ;;
    current_box_version)
        curl -sS "https://app.vagrantup.com/api/v1/box/Yohnah/Kubernetes" | jq '.current_version.version'
    ;;
    all_kubernetes_releases)
        curl -sS https://kubernetes.io/releases/ | grep -i "latest release" | grep -oE '([0-9]+)\.([0-9]+)\.([0-9]+)' | sed 's/ //g' | jq -ncR '[inputs]' | sed 's/"/\\"/g'
    ;;
    checkifbuild)
        if [ "$CURRENT_KUBERNETES_VERSION" = "$CURRENT_BOX_VERSION" ]; then
            echo "false"
        else
            echo "true"
        fi
    ;;
esac

exit 0