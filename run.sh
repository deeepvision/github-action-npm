#!/bin/bash

set -e

function main() {
  PACKAGE_FULL_NAME=$(node -p "require('./package.json').name")
  echo "📦 Working on package: $PACKAGE_FULL_NAME"

  IFS='/' read -ra ADDR <<< "$PACKAGE_FULL_NAME"
  PACKAGE_SCOPE=${ADDR[0]}
  PACKAGE_NAME=${ADDR[1]}
  echo "📦 Package scope: $PACKAGE_SCOPE"
  echo "📦 Package name: $PACKAGE_NAME"

  REGISTRY_VERSION=$(npm view $PACKAGE_FULL_NAME version)
  LOCAL_VERSION=$(node -p "require('./package.json').version")
  echo "📦 Local version: $LOCAL_VERSION"
  echo "📦 Registry version: $REGISTRY_VERSION"

  if [ "$REGISTRY_VERSION" = "$LOCAL_VERSION" ]; then
    echo "🚧 Package version is already published"
    exit 0
  fi

  echo "🔑 NPM Registry: Login to ${INPUT_REGISTRY}"
  echo "${PACKAGE_SCOPE}:registry=https://${INPUT_REGISTRY}" >> .npmrc && \
  echo "//${INPUT_REGISTRY}/:_authToken=${NPM_AUTH_TOKEN}" >> .npmrc && \

  echo "👷🛠️ Build package"
  npm ci
  npm run build

  echo "👷⬆️ Push to registry"
  if [ "$INPUT_ACCESS" = "public" ]; then
    npm publish --access public
  else
    npm publish
  fi
}

main
