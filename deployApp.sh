#!/bin/bash


checkStatus(){
export ANYPOINT_PROFILE="connAppProfile"

local appName=$1

appStatus="$(anypoint-cli runtime-mgr cloudhub-application describe "${appName}" -o json | jq .Status)"
#echo "----->App status ->$appStatus<-"

if [ "${appStatus}" == '"STARTED"' ]; 
	then
	echo "Condition status ----->true"
	else
	echo "Condition status ----->False"    
fi 

}

checkStatus $1
