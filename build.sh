#!/bin/bash
VERSION="1.0.0"
docker build -t gowin-dev:${VERSION} .
docker tag gowin-dev:${VERSION} gowin-dev:latest
