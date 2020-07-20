#!/usr/bin/env bash
set -e -o pipefail

if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed. Get it at bit.ly/getdockerce' >&2
  exit 1
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed. Get it at bit.ly/getdockercompose' >&2
  exit 1
fi

pushd "$(dirname "$0")" > /dev/null
  cat ascii/intro.art
  sleep 3
  docker-compose up -d --build --force-recreate
  docker-compose ps
  docker-compose exec cli /kata/cli.sh "$@"
  docker-compose down -v --rmi all
  cat ascii/outro.art
popd > /dev/null
