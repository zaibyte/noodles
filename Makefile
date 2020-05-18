CURDIR := $(shell pwd)

export PATH := $(CURDIR)/bin/:$(PATH)

all: go

init:
	mkdir -p $(CURDIR)/bin
check: init
	$(CURDIR)/scripts/checkpb.sh
go: check
	# Standalone GOPATH
	$(CURDIR)/scripts/generatepb.sh
	GO111MODULE=on go mod tidy
	GO111MODULE=on go build ./pkg/...

.PHONY: all
