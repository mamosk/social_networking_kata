#!/usr/bin/env bash
set -e -o pipefail -o noglob

# requirements:
# - curl
# - jq
# - pandoc
# - lynx

#########################################
### ENTRY POINT IS AT THE END OF FILE ###
#########################################

# cli prefix
PREFIX="> "

### PREPEND PREFIX TO EVERY OUTPUT LINE ###
# usage:   pipe to a command
# example: cat file.txt | cli
cli() {
  while read -r line
  do
    echo "$PREFIX$line"
  done
}

### UNRECOGNIZED COMMAND ###
unrecognized() {
  echo "$KATA unrecognized command: $1" 1>&2
}

### README COMMAND ###
readme() {
  curl -s "https://raw.githubusercontent.com/xpeppers/social_networking_kata/master/README.md" | pandoc | lynx -stdin
}

### HELP COMMAND ###
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

### POSTING COMMAND ###
# cmd:  <user name> -> <message>
# info: posts message to user timeline
# args: $1 user name
#       $2 -> (not used)
#       $3... message to be posted
# resp: silent command (no feedback)
posting() {
  curl -s --location --request POST "http://localhost:11881/posting?user=$1" \
    --header 'Content-Type: text/plain' \
    --data-raw "${*:3}" \
    >/dev/null
}

### READING COMMAND ###
# cmd:  <user name>
# info: reads messages from user timeline
# args: $1 user name
# resp: messages, from the most recent to the oldest, in the format:
#       <user> - <message> (<n> <seconds|minutes|hours> ago)
reading() {
  curl -s --location --request GET "http://localhost:11881/reading?user=$1" \
    | jq '. |= sort_by(.time) | reverse' \
    | jq --raw-output '.[] | .user + " - " + .post + " (" + .time + ")"' \
    | cli
}

### FOLLOWING COMMAND ###
# cmd:  <user name> follows <another user>
# info: subscribes user to another user timeline
# args: $1 user name (follower)
#       $2 another user (followed)
# resp: silent command (no feedback)
following() {
  curl -s --location --request PUT "http://localhost:11881/following?user=$1" \
    --header 'Content-Type: text/plain' \
    --data-raw "$2" \
    >/dev/null
}

### WALL COMMAND ###
# cmd:  <user name> wall
# info: read messages from user timeline and subscriptions
# args: $1 user name
# resp: messages, from the most recent to the oldest, in the format:
#       <user> - <message> (<n> <seconds|minutes|hours> ago)
wall() {
  curl -s --location --request GET "http://localhost:11881/wall?user=$1" \
    | jq '. |= sort_by(.time) | reverse' \
    | jq --raw-output '.[] | .user + " - " + .post + " (" + .time + ")"' \
    | cli
}

### MAIN COMMAND STARTING WITH USER NAME ###
username () {
  # return if empty line
  [ -z "$1" ] && return 0
  # check command after user name
  # each command calls a specific function
  case $2 in
    "->")
      posting "$@"
      ;;
    "")
      reading "$1"
      ;;
    "follows")
      following "$1" "$3"
      ;;
    "wall")
      wall "$1"
      ;;
    *)
      unrecognized "$2"
      ;;
  esac
}

### MAIN CLI FUNCTION ###
kata () {
  # loop until 'exit' command
  while read -r -e -p "$PREFIX"
  do
    # keep command in history to be reused
    history -s "$REPLY"
    # check command
    case "$REPLY" in
      # exit command
      "exit")
        exit 0
        ;;
      # help command
      "help")
        help
        ;;
      # command starting with user name
      # 
      *)
        username $REPLY
        ;;
    esac
  done
}

################################
### ENTRY POINT IS DOWN HERE ###
################################

# move to script directory
pushd "$(dirname "$0")" > /dev/null

# execute main cli function
kata "$@"

# restore original directory
popd > /dev/null
