# Makefile for building i66 CLI across multiple platforms

APP_NAME := i66
SRC_FILE := i66.org.go
BUILD_DIR := build
VERSION   := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
LDFLAGS   := -ldflags "-X main.version=$(VERSION)"

PLATFORMS := \
	linux/amd64 \
	linux/arm \
	linux/arm64 \
	darwin/amd64 \
	darwin/arm64 \
	windows/amd64

# Default target: build for local system
build:
	go build $(LDFLAGS) -o $(APP_NAME) $(SRC_FILE)

# Build for all supported platforms
build-all:
	@for platform in $(PLATFORMS); do \
		GOOS=$${platform%/*}; \
		GOARCH=$${platform#*/}; \
		dir=$(BUILD_DIR)/$$GOOS-$$GOARCH; \
		mkdir -p $$dir; \
		name=$(APP_NAME); \
		if [ "$$GOOS" = "windows" ]; then name=$(APP_NAME).exe; fi; \
		echo "Building $$dir/$$name..."; \
		GOOS=$$GOOS GOARCH=$$GOARCH go build $(LDFLAGS) -o $$dir/$$name $(SRC_FILE); \
	done

# Clean up all built files
clean:
	rm -rf $(APP_NAME) $(BUILD_DIR)

.PHONY: build build-all clean
