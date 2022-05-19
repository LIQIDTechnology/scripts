#!/bin/bash

checkStatus(){
#export ANYPOINT_PROFILE="connAppProfile"
#source ./exports.sh
echo "$ANYPOINT_PROFILE"
local appName=$1
echo "--App name->${appName}"
local lowApp=$( echo "$appName" | tr '[:upper:]' '[:lower:]')
echo "--Low App name->${lowApp}"
#anypoint-cli
#appStatus=$(anypoint-cli runtime-mgr cloudhub-application describe "$lowApp" -o json | jq '.Status')
#appStatus="$(anypoint-cli runtime-mgr cloudhub-application describe content -o json | jq)"

appStatus="$(anypoint-cli runtime-mgr cloudhub-application describe "$lowApp" -o json | jq .Status)"

local out=$(echo "$appStatus" | sed 's/^.//;s/.$//')

echo "-->$out<--"

if [ "$out" == "STARTED" ]; then
	echo "Condition status ----->true"
	else
	echo "Condition status ----->False"    
fi 

}

checkStatus $1

