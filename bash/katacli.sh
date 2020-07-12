#!/usr/bin/env bash
set -eo pipefail

# cli prefix
KATA="kata>"

unrecognized() {
  echo "$KATA unrecognized command: $1" 1>&2
}

readme() {
  curl -s "https://raw.githubusercontent.com/xpeppers/social_networking_kata/master/README.md" | pandoc | lynx -stdin
}

help() {
  cat <<-EOF

kata cli commands:
  <user name> -> <message>           -> post message to user timeline
  <user name>                        -> read messages from user timeline
  <user name> follows <another user> -> subscribe user to another user timeline
  <user name> wall                   -> read messages from user timeline and subscriptions
  
  exit -> exit the cli
  help -> read this help
  kata -> read full readme of kata requirements

kata full readme: https://github.com/xpeppers/social_networking_kata

EOF
}

posting() {
  curl --location --request POST "http://localhost:11881/posting?user=$1" \
    --header 'Content-Type: text/plain' \
    --data-raw "$2"
}

reading() {
  curl --location --request GET "http://localhost:11881/reading?user=$1"
  echo
}

following() {
  curl --location --request PUT "http://localhost:11881/following?user=$1" \
    --header 'Content-Type: text/plain' \
    --data-raw "$2"
  echo
}

wall() {
  curl --location --request GET "http://localhost:11881/wall?user=$1"
  echo
}

apicall () {
  # return if empty line
  [ -z $1 ] && return 0
  case $2 in
    "->") posting $1 $3;;
    "") reading $1;;
    "follows") following $1 $3;;
    "wall") wall $1;;
    *) unrecognized $2;;
  esac
}

kata () {
  while read -r -p "$KATA "
  do
    case $REPLY in
      "exit") exit 0;;
      "help") help 0;;
      *) apicall $REPLY;;
    esac
  done
}

pushd "$(dirname "$0")" > /dev/null
    kata "$@"
popd > /dev/null
