AMBER ?= $(HOME)/.local/bin/amber

.PHONY: build
build:
	"$(AMBER)" build src/create.ab scripts/create.sh
	"$(AMBER)" build src/change-name.ab scripts/change-name.sh
