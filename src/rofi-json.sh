#!/bin/bash

# the code here is stolen from:
# https://github.com/luiscrjunior/rofi-json/blob/master/rofi-json.sh

user_file="$(eval echo ${1})"

if [[ "$user_file" = /* ]]
then
  config_file="$user_file"
else
  cwd=$(dirname $0)
  config_file="${cwd}/${user_file}"
fi

json=$(cat ${config_file})

if [ $# -eq 1 ]; then
  echo "$json" | jq -cr '.[] | "\(.name)|\(.description)|\(.command)"' |
  while IFS= read -r line; do
    IFS="|" read -r name description command <<< "$line"

    if [[ $name == "null" ]]; then
      continue
    fi

    printf "%s\0\n" "$name"
  done
  exit 1
fi

if [ $# -eq 2 ]; then

  selected="$2"
  task=$(echo "$json" | jq ".[] | select(.name == \"$selected\")")

  if [[ "$task" == "" ]]; then
    exit 1
  fi

  command=$(echo $task | jq -j ".command")

  if [[ $command == "null" ]]; then
    command=$(echo $task | jq -j ".name")
  fi

  coproc bash -c "$command"
  exit
fi
