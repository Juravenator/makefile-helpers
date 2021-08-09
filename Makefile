SHELL:=/bin/bash
.DEFAULT_GOAL:=help

include vars/git.mk
include vars/uname.mk

##
### main section
##

help:: ## I override help and print the version string above
	@echo "Makefile-shared v${GIT_DERIVED_SEMVER} on ${COMMON_ARCH}"

## This is something very complicated.
# That's why there's this long extra explanation here
# that people can access with `make explain something`
.PHONY: something
something: ## run me if you want to make something
	@echo "You get nothing!"
	@echo "You lose!"
	@echo "Good day sir!"

include help.mk