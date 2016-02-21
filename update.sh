#!/usr/bin/env bash

# DO NOT USE THIS WITH REDIRECTION
# This don't overwrite specified files. Create only.

mktemp() {
  command mktemp 2>/dev/null || command mktemp -t tmp
}

die() {
  err "$@"
  exit 1
}

err() {
  echo "$@" 1>&2
}

precondition() {
  local query="$1"
  local filepath="$2"
  local seeds="$3"

  # whether specified query appear in the same lines (line numbers)
  diff <(numbering "$query" "$filepath"|awk '$0=$1') <(cat "$seeds"|awk '$0=$1')
}

numbering() {
  local query="$1"
  local filepath="$2"
  grep -n "$query" "$filepath"
}

revise() {
  local awk_file="$1"
  local filepath="$2"
  local seeds="$3"

  awk -f "$awk_file" "$filepath" "$seeds"
}

create_awk_file() {
  local this_file="$1"
  local awk_file=$(mktemp)
  local from_bottom=$(tail -r ${this_file}|grep -n .|grep "#### template"|head -1|grep -o "[0-9]*")
  cat "$this_file"|tail -${from_bottom} > "$awk_file"
  echo "$awk_file"
}

main() {
  [[ ! $# -gt 3 ]] && die './update ${param name} ${copyee file} ${copy_to}...'

  local awk_file=$(create_awk_file "$0")
  trap "rm $awk_file" 1 2 3 15

  shift 1

  local query="$1"
  local copyee_file="$2"

  [[ ! -f "$copyee_file" ]] && die "'$copyee_file' not found."

  local tempfile=$(mktemp)
  trap "rm $awk_file $tempfile" 1 2 3 15

  shift 2

  # create seeds
  numbering "$query" "$copyee_file" > "$tempfile"
  # FORMAT => '${LINE_NUMBER}: ${TARGET_LINE}'

  local f
  for f in $@; do
    [[ ! -f "$f" ]] && err "'$f' not found." && continue
    if precondition "$query" "$f" "$tempfile"; then
      revise "$awk_file" "$f" "$tempfile" > "${f}.revised"
    else
   	  err "'$f is invalid"
    fi
  done
}

main "$0" "$@"

exit 0

#### template-begin
BEGIN {
	i = 1

    while (getline < ARGV[1] > 0) {
        contents[i":"] = $0;
        i++;
    }

    while (getline < ARGV[2] > 0) {
    	contents[$1] = substr($0, length($1) + 1, length($0) - length($1));
    }

    close(ARGV[1]);
    close(ARGV[2]);

    for (j = 1; j < i; j++) {
    	print contents[j":"]
    }
}
