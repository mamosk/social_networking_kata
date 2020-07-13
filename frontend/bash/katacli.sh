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
  echo "${PREFIX}unrecognized command: $1" 1>&2
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
    # demo accepts only last 10 seconds
    [ "$demo" = true ] && [ "$diff" -ge $((commands * 3)) ] && return
    # compute human-readable difference
    local i=0
    while [ $diff -ge 60 ] && [ $i -lt ${#TIMEWORDS[@]} ]
    do
      i=$((i+1))
      diff=$((diff/60))
    done
    local timeword
    timeword="${TIMEWORDS[$i]}"
    if [ $diff -gt 1 ]
    then
      timeword="${timeword}s"
    fi
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
posting_full() {
  # using backend
  curl -s --location --request POST "${API_BASE_URL}posting?user=$1"\
    --header 'Content-Type: text/plain' \
    --data-raw "${*:3}"
}
posting_mono() {
  # without backend
  pushd "$MONO_PATH" > /dev/null
    # make <user name> directory if missing
    # user name not checked: assuming sunny day scenario :)
    mkdir -p "$1"
    # write post into <user name>/<epoch>.post file
    echo "${*:3}" > "$1/$(date -u "+%s").post"
  popd > /dev/null
}
posting_switch() {
  case "$MODE" in
    full) posting_full "$@";;
    mono) posting_mono "$@";;
  esac
}
posting() {
  posting_switch "$@"  >/dev/null
}

### READING COMMAND ###
# cmd:  <user name>
# info: reads messages from user timeline
# args: $1 user name
# resp: messages, from the most recent to the oldest, in the format:
#       <user name> - <message> (<n> <seconds|minutes|hours> ago)
reading_full() {
  # using backend
  curl -s --location --request GET "${API_BASE_URL}reading?user=$1"
}
reading_mono() {
  # without backend
  pushd "$MONO_PATH" > /dev/null
    if [ -d "$1" ]
    then
      # user found: cd into <user name> directory
      pushd "$1" > /dev/null
        set +o noglob
          # file names are <epoch>.post
          posts="*.post"
          # mock real api JSON array
          # open array
          local jsons='['
          for post in $posts
          do
            # user is the function argument
            local user="$1"
            # post is the file content
            local text
            text=$(<"$post")
            # zulu timestamp from file name
            local time
            time=${post%".post"}
            time=$(date -Iseconds -u -d "@$time")
            time=${time/"+00:00"/Z}
            # build json
            local json
            json=$( jq -n \
              --arg u "$user" \
              --arg p "$text" \
              --arg t "$time" \
              '{user: $u, post: $p, time: $t}' \
              )
            # append json to jsons array
            jsons="$jsons$json,"
          done
          # remove trailing ','
          jsons=${jsons::-1}
          # close array
          jsons="$jsons]"
          echo "$jsons"
        set -o noglob
      popd > /dev/null
    else
      # missing user
      echo '[]'
    fi
  popd > /dev/null
}
reading_switch() {
  case "$MODE" in
    full) reading_full "$@";;
    mono) reading_mono "$@";;
  esac
}
reading() {
  now
  reading_switch "$@" \
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
following_full() {
  # using backend
  curl -s --location --request PUT "${API_BASE_URL}following?user=$1" \
    --header 'Content-Type: text/plain' \
    --data-raw "$2"
}
following_mono() {
  pushd "$MONO_PATH" > /dev/null
    # if missing, write <user name>.follows file
    # user wall contains zir own posts, thus add user to file
    local follows="$1.follows"
    [[ -f "$follows" ]] || echo "$1" > "$follows"
    # if missing, append followed user to <user name>.follows file
    # user names not checked: assuming sunny day scenario :)
    grep -qxF "$2" "$follows" || echo "$2" >> "$follows"
  popd > /dev/null
}
following_switch() {
  case "$MODE" in
    full) following_full "$@";;
    mono) following_mono "$@";;
  esac
}
following() {
  following_switch "$@" >/dev/null
}

### WALL COMMAND ###
# cmd:  <user name> wall
# info: read messages from user timeline and subscriptions
# args: $1 user name
# resp: messages, from the most recent to the oldest, in the format:
#       <user name> - <message> (<n> <seconds|minutes|hours> ago)
wall_full() {
  # using backend
  curl -s --location --request GET "${API_BASE_URL}wall?user=$1"
}
wall_mono() {
  pushd "$MONO_PATH" > /dev/null
    # loop <user name>.follows lines: they are followed users
    local follows="$1.follows"
    while read -r line
    do
      reading_mono "$line"
    done < "$follows"
  popd > /dev/null
}
wall_switch() {
  case "$MODE" in
    full) wall_full "$@";;
    mono) wall_mono "$@";;
  esac
}
wall() {
  now
  wall_switch "$@" \
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
  case $1 in
    # normal execution
    "")
      # make standalone directory if needed
        [ "$MODE" = mono ] && mkdir -p .mono
      # loop until 'exit' command
      while read -r -e -p "$PREFIX" command
      do
        # keep command in history to be reused
        history -s "$command"
        # check command
        case "$command" in
          # exit command
          "exit")
            exit 0
            ;;
          # help command
          "help")
            help
            ;;
          # kata command to display github readme
          "kata")
            readme
            ;;
          # command starting with user name
          *)
            username $command
            ;;
        esac
      done
      ;;
    # run demo
    demo)
      # it's just a demo, bro
      demo=true
      # loop demo files
      set +o noglob
      for file in demo/*.demo
      do
      set -o noglob
      # count commands
      commands=$(wc -l < "$file")
        # loop demo file lines: they are the commands
        while read -r line
        do
          echo "${PREFIX}$line"
          username $line
          sleep $((RANDOM % 2 + 1))
        done < "$file"
      done
      # let user read a bit more
      sleep 3
      ;;
    # unrecognized command
    *)
      unrecognized "$1"
      ;;
  esac
}

################################
### ENTRY POINT IS DOWN HERE ###
################################
# check variables
if [ -z "$MODE" ]
then
  echo "${PREFIX}missing environment variable: MODE" >&2
  exit 1
fi
case "$MODE" in
  "full")
    if [ -z "$API_BASE_URL" ]
    then
      echo "${PREFIX}missing environment variable: API_BASE_URL" >&2
      exit 1
    fi
  ;;
  "mono")
    if [ -z "$MONO_PATH" ]
    then
      echo "${PREFIX}missing environment variable: MONO_PATH" >&2
      exit 1
    fi
    ;;
  *)
    echo "${PREFIX}unrecognized mode: $MODE" >&2
    exit 1;;
esac
# move to script directory
pushd "$(dirname "$0")" > /dev/null
  # execute main cli function
  kata "$@"
# restore original directory
popd > /dev/null
