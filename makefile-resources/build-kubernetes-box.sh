#!/bin/bash

echo "Init packer build for Kubernetes $CURRENT_KUBERNETES_VERSION version and $PROVIDER as provider"
cd packer; packer build -var "kubernetes_version=$CURRENT_KUBERNETES_VERSION" -var "debian_version=$CURRENT_DEBIAN_VERSION" -var "output_directory=$PACKER_DIRECTORY_OUTPUT" -only builder.$PROVIDER-iso.kubernetes packer.pkr.hcl