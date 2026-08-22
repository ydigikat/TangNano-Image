#!/bin/bash
VERSION="1.0.0"
docker build -t gowin-tang-dev:${VERSION} .
docker tag gowin-tang-dev:${VERSION} gowin-tang-dev:latest