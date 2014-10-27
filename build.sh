#! /bin/bash

#
# A little script I use to run the Packer build because I like to have comments in
# my JSON (documenting what everything is). But, that's not allowed:
#
#   https://plus.google.com/+DouglasCrockfordEsq/posts/RK8qyGVaGSr
#
# The script prefers to use `strip-json-comments` but will still work if there is a
# JSON artifact from an earlier build still around on the file system.
#

# Fail immediately on a non-zero exit code
set -e

# If we have strip-json-comments installed, we can build from the JSON source file
STRIP_JSON_SCRIPT=`which strip-json-comments`

# Test to make sure we have the external variables we need
if [[ ! -e vars.json ]]; then
  cp example-vars.json vars.json
  echo "  Please edit the project's vars.json file before running this script"
  echo "   Leave the _password vars blank if you want them to be autogenerated"
  exit 1
fi

# The main work of the script
function build_graphite {
  packer validate -var-file=vars.json graphite.json

  # Looks to see if the vars file has any empty passwords; creates passwords if needed
  while read LINE; do
    if [ ! -z "$LINE" ]; then
      REPLACEMENT="_password\": \"`openssl rand -base64 12`\""

      if [[ ! -e .passwords_generated ]]; then
        PASSWORD_PATTERN="_password\": \"\""
      else
        PASSWORD_PATTERN="_password\": \"*\""
      fi

      NEWLINE="${LINE/$PASSWORD_PATTERN/$REPLACEMENT}"

      if [ "$NEWLINE" != "$LINE" ]; then
        touch .passwords_generated
      fi

      echo $NEWLINE
    fi
  done <vars.json > vars.json.new
  mv vars.json.new vars.json

  # If we're not running in CI, use vars file; else, use ENV vars
  if [ -z "$CONTINUOUS_INTEGRATION" ]; then
    packer build -var-file=vars.json graphite.json
  else
    echo "Running within a continuous integration server"
    GRAPHITE_ADMIN_PASSWORD=`openssl rand -base64 12`
    GRAPHITE_SECRET_KEY=`openssl rand -base64 12`
    echo $GRAPHITE_ADMIN_PASSWORD > graphite_admin_password
    echo $GRAPHITE_SECRET_KEY > graphite_secret_key

    packer -machine-readable build \
      -var "graphite_admin_password=${GRAPHITE_ADMIN_PASSWORD}" \
      -var "graphite_secret_key_password=${GRAPHITE_SECRET_KEY}" \
      graphite.json | tee packer.log
  fi
}

# If we have strip-json-comments installed, use JSON source file; else use derivative
if [[ -e $STRIP_JSON_SCRIPT ]]; then
  strip-json-comments packer-graphite.json > graphite.json
  build_graphite
elif [[ -e graphite.json ]]; then
  build_graphite
else
  echo "  strip-json-comments needs to be installed to generate the graphite.json file"
  echo "    For instructions, see https://github.com/sindresorhus/strip-json-comments"
fi
