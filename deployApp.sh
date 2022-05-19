

checkStatus(){
#export ANYPOINT_PROFILE="connAppProfile"
anypoint-cli
local appName=$1
echo "--App name->${appName}"
local lowApp=$( echo "$appName" | tr '[:upper:]' '[:lower:]')
echo "--Low App name->${lowApp}"


appStatus="$(anypoint-cli runtime-mgr cloudhub-application describe "$lowApp" -o json | jq .Status)"

echo "----->App status ->$appStatus<-"

if [ "${appStatus}" == '"STARTED"' ]; 
	then
	echo "Condition status ----->true"
	else
	echo "Condition status ----->False"    
fi 

}

checkStatus $1

