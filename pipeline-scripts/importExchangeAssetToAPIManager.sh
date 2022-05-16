#!/bin/bash

echo Starting Exchange Asset Import to Anypoint API Manager...

API_PATH=$1
source $API_PATH/config.sh

source ./common.sh

VARS=( "ANYPOINT_HOST" "ANYPOINT_USERNAME" "ANYPOINT_PASSWORD" "ANYPOINT_ORG" "ANYPOINT_ENV" "MULE_TYPE" "MULE_WITHPROXY" "MULE_VERSION4ORABOVE" "MULE_DEPLOYMENTTYPE" "MULE_IMPLEMENTATIONURI" "MULE_SCHEME" "MULE_PORT" "MULE_PROXYPATH" "MULE_ASSETIDENTIFIER" "MULE_ASSETVERSION" "MULE_APIVERSION" )

checkEnvVariables VARS



APIINSTANCES=$(anypoint-cli api-mgr api list --assetId $MULE_ASSETIDENTIFIER --apiVersion $MULE_APIVERSION)
APIINSTANCECOUNT=$(echo -n "$APIINSTANCES" | wc -l)
APIINSTANCECOUNT=$(expr $APIINSTANCECOUNT - 1)	#Removing the header line
if [ $APIINSTANCECOUNT -gt 1 ]; then #Report Multiple instances
	onErrorExit 1 "Multiple instance ($APIINSTANCECOUNT) instances for API: $MULE_ASSETIDENTIFIER $MULE_APIVERSION. Please specify the exact API asset coordinates."
elif [ $APIINSTANCECOUNT -eq 1 ]; then	#Change specification of the API Instance
	DEBUG "API with asset $MULE_ASSETIDENTIFIER ($MULE_APIVERSION) already managed. Editing..."
	APIINSTANCEID=$(echo "${APIINSTANCES##*$'\n'}" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $2}')
	DEBUG "API instance ID that will be edited: $APIINSTANCEID"
	RESPONSE=$(anypoint-cli api-mgr api change-specification $APIINSTANCEID $MULE_ASSETVERSION)
	onErrorExit $? "Error while updating API $APIINSTANCEID specification to $MULE_ASSETVERSION. Error: $RESPONSE"
	DEBUG "API $APIINSTANCEID specification changed to $MULE_ASSETVERSION"
	#Fix this issue - Option --referencesUserDomain can not be used when --deploymentType value is "cloudhub" or "rtf"
	if [ "$MULE_DEPLOYMENTTYPE" == "cloudhub" ]; then
		RESPONSE=$(anypoint-cli api-mgr api edit --withProxy $MULE_WITHPROXY --muleVersion4OrAbove $MULE_VERSION4ORABOVE --deploymentType $MULE_DEPLOYMENTTYPE --uri $MULE_IMPLEMENTATIONURI --scheme $MULE_SCHEME --port $MULE_PORT --path $MULE_PROXYPATH $APIINSTANCEID)
	elif [ "$MULE_DEPLOYMENTTYPE" == "hybrid" ]; then
		RESPONSE=$(anypoint-cli api-mgr api edit --withProxy $MULE_WITHPROXY --muleVersion4OrAbove $MULE_VERSION4ORABOVE --deploymentType $MULE_DEPLOYMENTTYPE --uri $MULE_IMPLEMENTATIONURI --scheme $MULE_SCHEME --port $MULE_PORT --path $MULE_PROXYPATH --referencesUserDomain true $APIINSTANCEID)
	fi
	onErrorExit $? "Error while editing api $APIINSTANCEID. Error: $RESPONSE"
	INFO "API options successfully updated!"
	export APIINSTANCEID=$APIINSTANCEID
elif [ $APIINSTANCECOUNT -le 1 ]; then	#Create new API Instance as no instance found
	if [ "$MULE_DEPLOYMENTTYPE" == "cloudhub" ]; then
		RESPONSE=$(anypoint-cli api-mgr api manage --type $MULE_TYPE --withProxy $MULE_WITHPROXY --muleVersion4OrAbove $MULE_VERSION4ORABOVE --deploymentType $MULE_DEPLOYMENTTYPE --uri $MULE_IMPLEMENTATIONURI --scheme $MULE_SCHEME --port $MULE_PORT --path $MULE_PROXYPATH $MULE_ASSETIDENTIFIER $MULE_ASSETVERSION)
	elif [ "$MULE_DEPLOYMENTTYPE" == "hybrid" ]; then
		RESPONSE=$(anypoint-cli api-mgr api manage --type $MULE_TYPE --withProxy $MULE_WITHPROXY --muleVersion4OrAbove $MULE_VERSION4ORABOVE --deploymentType $MULE_DEPLOYMENTTYPE --uri $MULE_IMPLEMENTATIONURI --scheme $MULE_SCHEME --port $MULE_PORT --path $MULE_PROXYPATH --referencesUserDomain true $MULE_ASSETIDENTIFIER $MULE_ASSETVERSION)
	fi
	onErrorExit $? "Error while managing api $MULE_ASSETIDENTIFIER/$MULE_ASSETVERSION. Error: $RESPONSE "
	APIID=$(echo $RESPONSE | cut -d':' -f 2)
	export APIINSTANCEID=$APIID
fi