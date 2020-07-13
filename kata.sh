#!/usr/bin/env bash
set -e -o pipefail

if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

pushd "$(dirname "$0")" > /dev/null
  cat ascii/intro.art
  sleep 3
  pushd backend > /dev/null
    echo
    echo "Building services, please wait..."
    sleep 1
    docker-compose up -d --build --force-recreate
    echo
    echo "Initializing services, please wait..."
    sleep 3
    docker-compose ps
  popd > /dev/null
  pushd frontend > /dev/null
    echo
    echo "Building cli, please wait..."
    sleep 1
    docker-compose build
    echo
    echo "Initializing cli, please wait..."
    docker-compose run --rm cli /kata/cli.sh "$@"
  popd > /dev/null
  pushd backend > /dev/null
    docker-compose down
  popd > /dev/null
  cat ascii/outro.art
popd > /dev/null
