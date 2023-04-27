#!/bin/bash
set -Eeox pipefail

# requires an existing buildx builder, e.g:
# docker buildx create --name mybuilder --use --bootstrap

TAG=2.4.14
ORG=allaboutapps
IMAGE_NAME=swagger-codegen-cli
docker buildx build \
  --platform=linux/amd64,linux/arm64 \
  -f Dockerfile \
  -t "${ORG}/${IMAGE_NAME}:${TAG}" \
  -t "${ORG}/${IMAGE_NAME}:latest" \
  .
