#!/bin/bash

# Check if day arg was passed
if [ $# -eq 0 ]; then
  echo 'Please specify a day to run, e.g. `npm start 1` for day 1.'
  exit
fi

helpers="src/helpers.coffee"
src="src/day$1.coffee"
dist="dist/day$1.js"

# Check if file exists
if [ ! -f $src ]; then
  echo "File \`$src\` not found."
  exit
fi

echo -e "Compiling and running \`$src\`...\n"

# Compile helpers
coffee -o 'dist/' --compile $helpers

# Compile day's script
coffee -o 'dist/' --compile $src
node $dist
