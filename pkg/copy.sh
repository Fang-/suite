#!/bin/bash
# for documentation, see the readme

from=${1}
into=${2}
root=${3:-'../..'}
base=${4:-'dep.txt'}
deps="${from}/dep.txt"
deep=""
goal="/"

#NOTE that we pipe echoes to stderr, so that weinterleave nicely with
#     potential cp errors. how to make stdout linebuffered (or unbuffered)
#     so that we don't have to do this, remains a mystery...

if [ "$from" == "" ] || [ "$into" == "" ]; then
  echo 'arguments: pkg-dir dest-dir (dep-dir)' >/dev/stderr;
  exit 1;
fi;

function rake() { # arg $1: dep.txt filepath
  file=$1
  if [ ! -f $file ]; then
    echo "no depfile at $file, just copying pkg contents..." >/dev/stderr;
  else
    while IFS='' read -r line || [[ -n "${line}" ]]; do
      if [[ $line = "#"* ]]; then
        :
      elif [[ $line = "> "* ]]; then
        goal=${line:2};
        echo "- copying into $into/$goal" >/dev/stderr;
        mkdir -p $into/$goal;
      elif [[ $line = "< "* ]]; then
        deep=${line:2};
        echo "- copying from $root/$deep" >/dev/stderr;
      elif [[ $line != "" ]]; then
        cp -RL $root/$deep/$line $into/$goal;
      fi;
    done < $file;
    deep="";
    goal="/";
  fi;
};

echo "copying into $into..." >/dev/stderr;

echo "copying default dependencies per $base..." >/dev/stderr;
rake $base;

echo "copying pkg dependencies per $deps..." >/dev/stderr;
rake $deps;

echo "copying pkg files from $from/*..." >/dev/stderr;
cp -RL $from/* $into/;
rm $into/dep.txt;

echo "done! (:";

