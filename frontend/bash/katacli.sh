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

# words for human-readable <time> ago
TIMEWORDS=(second minute hour)

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

### STORE GLOBAL CURRENT TIME IN SECONDS ###
now() {
  now=$(date -u "+%s")
}

ago() {
  while read -r line
  do
    # extract timestamp from user posted message display string
    local ago
    ago=$(echo "$line" | grep -Eo '\([0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-6][0-9](.[0-9]{3})?Z\)')
    # remove leading '(' and trailing ')'
    ago=${ago:1}
    ago=${ago::-1}
    # timestamp string to be replaced
    local zulu="$ago"
    # get old date in seconds
    ago=$(date -u -d "$ago" "+%s")
    # get difference in second
    local diff
    diff=$((now - ago))
    # compute human-readable difference
    local i=0
    while [ $diff -ge 60 ] && [ $i -lt ${#TIMEWORDS[@]} ]
    do
      i=$((i+1))
      diff=$((diff/60))
    done
    local timeword
    timeword="${TIMEWORDS[$i]}$([[ $diff -gt 1 ]] && echo s)"
    diff="$diff $timeword"
    echo "${line/"$zulu"/"$diff ago"}"
  done
}

### POSTING COMMAND ###
# cmd:  <user name> -> <message>
# info: posts message to user timeline
# args: $1 user name
#       $2 -> (not used)
#       $3... message to be posted
# resp: silent command (no feedback)
posting() {
  curl -s --location --request POST "$API_BASE_URL/posting?user=$1" \
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
  now
  curl -s --location --request GET "$API_BASE_URL/reading?user=$1" \
    | jq '. |= sort_by(.time) | reverse' \
    | jq --raw-output '.[] | .user + " - " + .post + " (" + .time + ")"' \
    | ago \
    | cli
}

### FOLLOWING COMMAND ###
# cmd:  <user name> follows <another user>
# info: subscribes user to another user timeline
# args: $1 user name (follower)
#       $2 another user (followed)
# resp: silent command (no feedback)
following() {
  curl -s --location --request PUT "$API_BASE_URL/following?user=$1" \
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
  now
  curl -s --location --request GET "$API_BASE_URL/wall?user=$1" \
    | jq '. |= sort_by(.time) | reverse' \
    | jq --raw-output '.[] | .user + " - " + .post + " (" + .time + ")"' \
    | ago \
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
