.PHONY: init validate build clean all

PACKER ?= packer

init:
	$(PACKER) init .

validate:
	$(PACKER) validate .

build:
	$(PACKER) build .

clean:
	rm -rf output/

all: init validate build
