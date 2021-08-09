# Linux: 'linux'
# MacOS: 'darwin'
OS_UNAME_S := $(shell uname -s | tr '[:upper:]' '[:lower:]')
# x86_64: 'x86_64'
# Apple M1: 'arm64'
OS_UNAME_M := $(shell uname -m)

# These days, in the wild you see 'amd64' rather than 'x86_64'
COMMON_ARCH.x86_64 := amd64
COMMON_ARCH := $(or ${COMMON_ARCH.${OS_UNAME_M}},${OS_UNAME_M})
