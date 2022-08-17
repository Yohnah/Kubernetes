export CURRENT_BOX_VERSION := $(shell TYPE=current_box_version sh ./makefile-resources/get-versions.sh)
export CURRENT_KUBERNETES_VERSION := $(shell TYPE=current_kubernetes_version sh ./makefile-resources/get-versions.sh)
export CURRENT_DEBIAN_VERSION := $(shell TYPE=current_debian_version sh ./makefile-resources/get-versions.sh)
export ALLKUBERNETESRELEASES := $(shell TYPE=all_kubernetes_releases sh ./makefile-resources/get-versions.sh)
export OUTPUT_DIRECTORY := /tmp
export PACKER_DIRECTORY_OUTPUT := $(OUTPUT_DIRECTORY)/packer-build
export DATETIME := $(shell date "+%Y-%m-%d %H:%M:%S")
export PROVIDER := virtualbox
export MANIFESTFILE := $(PACKER_DIRECTORY_OUTPUT)/$(CURRENT_KUBERNETES_VERSION)/manifest.json
export UPLOADER_DIRECTORY := $(PACKER_DIRECTORY_OUTPUT)/toupload

.PHONY: all versions checkifbuild

all: version build test

versions: 
	@echo "========================="
	@echo Current Kubernetes Version: $(CURRENT_KUBERNETES_VERSION)
	@echo Current Box Version: $(CURRENT_BOX_VERSION)
	@echo Current Debian Version: $(CURRENT_DEBIAN_VERSION)
	@echo Provider: $(PROVIDER)
	@echo "========================="
	@echo ::set-output name=kubernetesversion::$(CURRENT_KUBERNETES_VERSION)
	@echo ::set-output name=debianversion::$(CURRENT_DEBIAN_VERSION)
	@echo ::set-output name=boxversion::$(CURRENT_BOX_VERSION)
	@echo ::set-output name=allkubernetesreleases::$(ALLKUBERNETESRELEASES)

checkifbuild:
	@echo "========================="
	@echo New kubernetes box must be built: $(shell CURRENT_KUBERNETES_VERSION=$(CURRENT_KUBERNETES_VERSION) CURRENT_BOX_VERSION=$(CURRENT_BOX_VERSION) TYPE=checkifbuild sh ./makefile-resources/get-versions.sh)
	@echo "========================="
	@echo ::set-output name=verdict::$(shell CURRENT_KUBERNETES_VERSION=$(CURRENT_KUBERNETES_VERSION) CURRENT_BOX_VERSION=$(CURRENT_BOX_VERSION) TYPE=checkifbuild sh ./makefile-resources/get-versions.sh)

requirements:
	mkdir -p $(PACKER_DIRECTORY_OUTPUT)/$(CURRENT_KUBERNETES_VERSION)/$(PROVIDER)
	mkdir -p $(PACKER_DIRECTORY_OUTPUT)/toupload
	mkdir -p $(PACKER_DIRECTORY_OUTPUT)/test/$(CURRENT_KUBERNETES_VERSION)/$(PROVIDER)

build: requirements
	sh ./makefile-resources/build-kubernetes-box.sh
	@echo ::set-output name=manifestfile::$(MANIFESTFILE)

add_box:
	sh ./makefile-resources/add-box.sh

del_box:
	sh ./makefile-resources/del-box.sh

upload:
	sh ./makefile-resources/upload-kubernetes-box.sh

clean:
	rm -fr $(PACKER_DIRECTORY_OUTPUT) || true