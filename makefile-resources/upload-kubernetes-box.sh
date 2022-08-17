#!/bin/bash

if [[ "$PROVIDER" == *"vmware"* ]];
then
    HyperVisor="vmware_desktop"
else
    HyperVisor=$PROVIDER
fi

export DATETIME=$(date "+%Y-%m-%d %H:%M:%S")

BOXFILE=$(cat /tmp/packer-build/$CURRENT_KUBERNETES_VERSION/manifest.json | jq '.builds | .[].files | .[].name' | grep "$CURRENT_KUBERNETES_VERSION" | grep "$PROVIDER" | sed 's/"//g' | uniq)

echo "Box $BOXFILE found, uploading..." 
vagrant cloud version create Yohnah/Kubernetes $CURRENT_KUBERNETES_VERSION || true
vagrant cloud version update -d "$(cat ./makefile-resources/uploading-box-notification-template.md | envsubst)" Yohnah/Kubernetes $CURRENT_KUBERNETES_VERSION
vagrant cloud provider delete -f Yohnah/Kubernetes $HyperVisor $CURRENT_KUBERNETES_VERSION || true
SHASUM=$(shasum $BOXFILE | awk '{ print $1 }')
vagrant cloud provider create --timestamp --checksum-type sha1 --checksum $SHASUM Yohnah/Kubernetes $HyperVisor $CURRENT_KUBERNETES_VERSION
vagrant cloud provider upload Yohnah/Kubernetes $HyperVisor $CURRENT_KUBERNETES_VERSION $BOXFILE
vagrant cloud version update -d "$(cat ./makefile-resources/box-version-description-template.md | envsubst)" Yohnah/Kubernetes $CURRENT_KUBERNETES_VERSION
vagrant cloud version release -f Yohnah/Kubernetes $CURRENT_KUBERNETES_VERSION || true
echo "Box $BOXFILE uploaded"