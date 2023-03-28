#!/bin/sh

set -e

function main() {
  PACKAGE_FULL_NAME=$(node -p "require('./package.json').name")
  IFS='/' read -ra ADDR <<< "$PACKAGE_FULL_NAME"
  PACKAGE_SCOPE=${ADDR[0]}
  PACKAGE_NAME=${ADDR[1]}

  REGISTRY_VERSION=$(npm view $PACKAGE_FULL_NAME version)
  LOCAL_VERSION=$(node -p "require('./package.json').version")

  if [ "$REGISTRY_VERSION" = "$LOCAL_VERSION" ]; then
    echo "Package version is already published"
    exit 0
  fi

  echo "${PACKAGE_SCOPE}:registry=https://${INPUT_REGISTRY}" >> .npmrc && \
  echo "//${INPUT_REGISTRY}/:_authToken=${NPM_AUTH_TOKEN}" >> .npmrc && \

  npm ci
  npm run build
  npm publish
}

main
