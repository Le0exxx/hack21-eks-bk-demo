# Use some sensible default shell settings
SHELL := /bin/bash
.ONESHELL:
.SILENT:

WORKING_DIR=/app

export IMAGE_TAG = ${APP_NAME}:${REVISION}

.PHONY: build
build:
	docker build --tag ${IMAGE_TAG} .

.PHONY: publish
publish:
	./publish-image.sh
