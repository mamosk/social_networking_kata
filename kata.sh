#!/usr/bin/env bash

if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

pushd "$(dirname "$0")" > /dev/null
  cat kata.art
  docker-compose up -d --build --force-recreate
popd > /dev/null
