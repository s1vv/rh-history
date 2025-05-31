#!/bin/bash

cmd="$1"
cmd="${cmd#"${cmd%%[![:space:]]*}"}"
cmd="${cmd%"${cmd##*[![:space:]]}"}"

# excluding commands
skip=("rh" "cd" "clear" "exit" "pwd" "rm" "sudo" "kill" "history")

for s in "${skip[@]}"; do
    if [[ "$cmd" == "$s"* ]]; then
        exit 0
    fi
done

echo -e "$(pwd)\t$cmd" >> ~/.rh_history

