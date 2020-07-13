#!/usr/bin/env bash
set -e -o pipefail -o noglob

# cli prefix
PREFIX="> "

##############
### ERRORS ###
##############

### WORD IN USER COMMAND NOT RECOGNIZED ###
unrecognized() {
  echo "${PREFIX}unrecognized: $1" 1>&2
}

### DEPENDENCY NOT INSTALLED ###
unknown() {
  echo "${PREFIX}dependency not installed: $1" 1>&2
  echo "${PREFIX}maybe you can run: apt-get install $1" 1>&2
}

####################
### REQUIREMENTS ###
####################

# dependencies
DEPENDENCIES=(curl jq pandoc lynx)

### DEPENDENCIES CHECK ###
depcheck(){
  for dependency in "${DEPENDENCIES[@]}"
  do
    if ! [ -x "$(command -v "$dependency")" ]
    then
      unknown "$dependency"
      exit 1
    fi
  done
}

### ENVIRONMET VARIABLES CHECK ###
varcheck() {
  # MODE is mandatory
  if [ -z "$MODE" ]
  then
    echo "${PREFIX}environment variable not set: MODE" >&2
    echo "${PREFIX}maybe you can run: export MODE=mono" >&2
    exit 1
  fi
  case "$MODE" in
    "full")
      # API_BASE_URL is mandatory in 'full' mode
      if [ -z "$API_BASE_URL" ]
      then
        echo "${PREFIX}environment variable not set: API_BASE_URL" >&2
        echo "${PREFIX}maybe you can run: export API_BASE_URL=http://localhost:11881/" >&2
        exit 1
      fi
    ;;
    "mono")
      # MONO_PATH defaults to <script directory>/.mono in 'mono' mode
      if [ -z "$MONO_PATH" ]
      then
        MONO_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1; pwd -P )/.mono"
      fi
      ;;
    *)
      echo "${PREFIX}mode not available: $MODE" >&2
      exit 1
      ;;
  esac
}

### ALL-REQUIREMENTS CHECK ###
reqcheck() {
  depcheck # check dependencies
  varcheck # check environment variables
}

#############
### UTILS ###
#############

### PREPEND PREFIX TO EVERY OUTPUT LINE ###
# usage:   pipe to a command
# example: cat file.txt | cli
cli() {
  while read -r line
  do
    echo "$PREFIX$line"
  done
}

### CURRENT EPOCH ###
now() {
  now=$(date -u "+%s")
}

# words for human-readable <time> ago
TIMEWORDS=(second minute hour)

### FROM ZULU TIME TO '<n> seconds|minutes|hours ago' ###
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
    [ "$demo" = true ] && [ "$diff" -ge $((commands * 3)) ] && continue
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
    "full") posting_full "$@";;
    "mono") posting_mono "$@";;
  esac
}
posting() {
  posting_switch "$@" >/dev/null
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
    "full") reading_full "$@";;
    "mono") reading_mono "$@";;
  esac
}
reading() {
  now
  reading_switch "$@" | jq '. |= sort_by(.time) | reverse' | jq --raw-output '.[] | .user + " - " + .post + " (" + .time + ")"' | ago | cli
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
    --data-raw "$3"
}
following_mono() {
  # without backend
  pushd "$MONO_PATH" > /dev/null
    # if missing, write <user name>.follows file
    # user wall contains zir own posts, thus add user to file
    local follows="$1.follows"
    [[ -f "$follows" ]] || echo "$1" > "$follows"
    # if missing, append followed user to <user name>.follows file
    # user names not checked: assuming sunny day scenario :)
    grep -qxF "$3" "$follows" || echo "$3" >> "$follows"
  popd > /dev/null
}
following_switch() {
  case "$MODE" in
    "full") following_full "$@";;
    "mono") following_mono "$@";;
  esac
}
following() {
  case $4 in
    "") following_switch "$@" >/dev/null;;
    *)  unrecognized "$4";;
  esac
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
  # without backend
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
    "full") wall_full "$@";;
    "mono") wall_mono "$@";;
  esac
}
wall() {
  case $4 in
    "") now
        wall_switch "$@" | jq '. |= sort_by(.time) | reverse' | jq --raw-output '.[] | .user + " - " + .post + " (" + .time + ")"' | ago | cli;;
    * ) unrecognized "$4";;
  esac
}

################
### COMMANDS ###
################

### <USER NAME> COMMAND ###
username () {
  # return if empty line
  [ -z "$1" ] && return 0
  # check command after user name
  # each command calls a specific function
  case $2 in
    "->"      ) posting "$@";;
    ""        ) reading "$@";;
    "follows" ) following "$@";;
    "wall"    ) wall "$@";;
    *         ) unrecognized "$2";;
  esac
}

### HELP COMMAND ###
help() {
  cat <<-EOF

kata commands:
  <user name> -> <message>           -> post message to user timeline
  <user name>                        -> read messages from user timeline
  <user name> follows <another user> -> subscribe user to another user timeline
  <user name> wall                   -> read messages from user timeline and subscriptions

utility commands:
  exit -> exit the cli
  help -> read this help
  kata -> read full readme of kata requirements
  mode -> tell if running in:
          - 'full' mode: attached to an API server which handles user data
          - 'mono' mode: handling user data using the file system

kata readme: https://github.com/xpeppers/social_networking_kata

EOF
}

### KATA COMMAND ###
kata() {
  curl -s "https://raw.githubusercontent.com/xpeppers/social_networking_kata/master/README.md" | pandoc | lynx -stdin
}

### MODE COMMAND ###
mode() {
  echo "$PREFIX$MODE"
}

############
### MAIN ###
############

### MAIN CLI LOOP ###
main () {
  # make standalone directory if needed
  [ "$MODE" = mono ] && mkdir -p "$MONO_PATH"
  case $1 in
    # normal interactive session
    "")
      # loop until 'exit' command
      while read -r -e -p "$PREFIX" command
      do
        # keep command in history to be reused
        history -s "$command"
        # check command
        case "$command" in
          "exit" ) exit 0;;
          "help" ) help;;
          "kata" ) kata;; # display github readme
          "mode" ) mode;; # display github readme
          *      ) username $command;;
        esac
      done
      ;;
    # demo non-interactive session
    "demo")
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
      sleep 2
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
# check requirements
reqcheck
# move to script directory
pushd "$(dirname "$0")" > /dev/null
  # run main cli loop
  main "$@"
# restore original directory
popd > /dev/null
