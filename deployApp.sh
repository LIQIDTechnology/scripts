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

if [ "$out" = "STARTED" ]; then
	echo "Condition status ----->true"
anypoint-cli runtime-mgr cloudhub-application modify "${apiName}" /app/target/*.jar --workerSize "0.1" --runtime "4.4.0" --workers "1" --output json
	else
	echo "Condition status ----->False"    
	anypoint-cli runtime-mgr cloudhub-application deploy "${apiName}" /app/target/*.jar --workerSize "0.1" --runtime "4.4.0" --workers "1" --output json
fi 

}

checkStatus $1

