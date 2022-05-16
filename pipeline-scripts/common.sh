#!/bin/bash

#source ./exports.sh

#TEMP solution
#alias anypoint-cli=/home/ec2-user/.nvm/versions/node/v12.9.1/bin/anypoint-cli
alias anypoint-cli=/usr/local/bin/anypoint-cli
#alias python3.7=/usr/local/bin/python3.7
#alias yq=/usr/local/bin/yq
#alias jq=/usr/local/bin/jq

function errorIfVariableNull
{
  if [[ -z ${!1} ]]
  then
    echo "ERROR: The environment variable '${1}' is null or empty!"
    exit 1
  fi
}

function now {
  echo "$(date +"%F %T")"
}

function DEBUG {
	if [ ! -z $ANYPOINT_CLI_DEBUG ]; then
	   echo -e "$(now) - DEBUG: $1"
	fi
}

function INFO {
  echo -e "$(now) - INFO: $1"
}

function WARN {
  echo -e "$(now) - WARN: $1"
}

function onErrorExit {
	if [ $1 -gt 0 ]; then
		echo "ERROR: $2"
		exit $1
	fi 
}

if [ ! -z $ANYPOINT_CLI_SH_TRACING ]; then
	set -o xtrace
fi

function checkEnvVariables {
  VARS=$1
  for envVar in "${VARS[@]}"
  do
    DEBUG "Checking $envVar is set"
    if [ -z "${!envVar}" ]; then
    echo "Please set variable $envVar"
          exit 1
    else
    DEBUG "Variable $envVar set"
    fi
  done
}