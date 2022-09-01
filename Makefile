export CURRENT_BOX_VERSION := $(shell TYPE=current_box_version sh ./makefile-resources/get-versions.sh)
export CURRENT_KUBERNETES_VERSION := $(shell TYPE=current_kubernetes_version sh ./makefile-resources/get-versions.sh)
export ALLKUBERNETESRELEASES := $(shell TYPE=all_kubernetes_releases sh ./makefile-resources/get-versions.sh)
export PROVIDER := virtualbox
export BOX_NAME := kubernetes
export VAGRANT_CLOUD_REPOSITORY_BOX_NAME := Yohnah/Kubernetes
export CURRENT_VERSION := $(CURRENT_KUBERNETES_VERSION)

.PHONY: all versions requirements checkifbuild build add_box del_box upload clean

all: version build test

requirements:
	git submodule init
	git submodule update --remote --merge

versions: 
	@echo "========================="
	@echo Current Kubernetes Version: $(CURRENT_KUBERNETES_VERSION)
	@echo Current Box Version: $(CURRENT_BOX_VERSION)
	@echo Provider: $(PROVIDER)
	@echo "========================="
	@echo ::set-output name=kubernetesversion::$(CURRENT_KUBERNETES_VERSION)
	@echo ::set-output name=boxversion::$(CURRENT_BOX_VERSION)
	@echo ::set-output name=allkubernetesreleases::$(ALLKUBERNETESRELEASES)
	cd Debian; make versions

checkifbuild:
	@echo "========================="
	@echo New kubernetes box must be built: $(shell CURRENT_KUBERNETES_VERSION=$(CURRENT_KUBERNETES_VERSION) CURRENT_BOX_VERSION=$(CURRENT_BOX_VERSION) TYPE=checkifbuild sh ./makefile-resources/get-versions.sh)
	@echo "========================="
	@echo ::set-output name=verdict::$(shell CURRENT_KUBERNETES_VERSION=$(CURRENT_KUBERNETES_VERSION) CURRENT_BOX_VERSION=$(CURRENT_BOX_VERSION) TYPE=checkifbuild sh ./makefile-resources/get-versions.sh)

build: requirements
	sh ./makefile-resources/prepare-build.sh
	cd Debian; make build BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_KUBERNETES_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)

add_box:
	cd Debian; make add_box BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_KUBERNETES_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)

del_box:
	cd Debian; make del_box BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_KUBERNETES_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)

upload:
	cd Debian/; make upload BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_KUBERNETES_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)

clean: 
	rm -fr Debian/
	git submodule init
	git submodule update --remote --merge
	cd Debian/; make clean BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_KUBERNETES_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)