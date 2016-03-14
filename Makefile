## PACKAGE INFO ##
PKG_NAME    = Lime
BUILD_CFG   = debug

## LOCATIONS ##
ROOT_DIR    = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
UV_PATH     =

## BUILD TARGETS ##
all: clean fetch libuv build

fetch:
	@echo "\n\033[1;33m>>> Fetch dependencies\033[0m"
	cd $(ROOT_DIR) && \
		swift build --fetch	
	@echo "\n\033[1;33m<<<\033[0m\n"

libuv:
	@echo "\n\033[1;33m>>> Build libuv\033[0m"
	$(eval UV_PATH = $(shell find $(ROOT_DIR) -type d ! \( -name *.build* -prune \) -name Libuv-*))
	$(MAKE) -C $(UV_PATH)
	@echo "\n\033[1;33m<<<\033[0m\n"

build:
	@echo "\n\033[1;33m>>> Build package\033[0m"
	$(eval UV_LIB_PATH = $(shell find $(ROOT_DIR) -type d ! \( -name ".build" -prune \) -name "lib"))
	cd $(ROOT_DIR) && \
		swift build -Xlinker -L$(UV_LIB_PATH)
	@echo "\n\033[1;33m<<<\033[0m\n"

run:
	$(ROOT_DIR)/.build/$(BUILD_CFG)/$(PKG_NAME)

clean:
	@echo "\n\033[1;33m>>> Clean\033[0m"
	rm -rf $(ROOT_DIR)/Packages
	cd $(ROOT_DIR) && \
		swift build --clean
	@echo "\n\033[1;33m<<<\033[0m\n"

.PHONY:
