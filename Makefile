DOCKER_IMAGE_PREFIX=zondax/builder-
DOCKER_IMAGE=${DOCKER_IMAGE_PREFIX}zemu

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)

ifdef INTERACTIVE
INTERACTIVE_SETTING:="-i"
TTY_SETTING:="-t"
else
INTERACTIVE_SETTING:=
TTY_SETTING:=
endif

ifdef HASH
HASH_TAG:=$(HASH)
else
HASH_TAG:=latest
endif

UNAME_CPU := $(shell uname -p)
PLATFORM := linux/amd64
ifeq ($(UNAME_CPU),arm)
	PLATFORM := linux/arm64
endif # $(OS)

build:
	cd src && docker buildx build --platform $(PLATFORM) --rm -f Dockerfile -t $(DOCKER_IMAGE):$(HASH_TAG) -t $(DOCKER_IMAGE):latest .

publish_login:
	docker login
publish: build
	docker push $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE):$(HASH_TAG)

publish: build
publish: publish_login
publish: publish

push: publish

pull:
	docker pull $(DOCKER_IMAGE):$(HASH_TAG)

define run_docker
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) \
	--privileged \
	-u $(shell id -u):$(shell id -g) \
	-v $(shell pwd):/project \
	-e DISPLAY=$(shell echo ${DISPLAY}) \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	$(1) \
	"$(2)"
endef


shell: build
	$(call run_docker,$(DOCKER_IMAGE):$(HASH_TAG),/bin/bash)
