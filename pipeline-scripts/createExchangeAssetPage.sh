#!/bin/bash

echo Starting Asset Page Creation in Anypoint Exchange...

API_PATH=$1
source $API_PATH/config.sh

source ./common.sh

VARS=("ANYPOINT_ORG" "MULE_ASSETIDENTIFIER" "MULE_ASSETVERSION" "MULE_ASSETPAGEMARKDOWNPATH" "MULE_ASSETCONFIGFILE" "MULE_PUTASSETTAGS" "MULE_PUTASSETCATEGORIES" "MULE_PYTHONSSLVERIFICATIONREQUIRED" )

for envVar in "${VARS[@]}"
do
  echo "Checking $envVar"
  if [ -z ${!envVar} ]; then
	echo "Please set variable $envVar"
        exit 1
  fi
done

for FILE in $MULE_ASSETPAGEMARKDOWNPATH/*;	#Read the Markdown files and upload them
do
	MARKDOWNFILENAME=$(echo ${FILE##*/})
	MARKDOWNFILENAMEWITHOUTEXTENSION=$(echo "${MARKDOWNFILENAME%.*}")
	RESPONSE=$(anypoint-cli exchange asset page upload $MULE_ASSETIDENTIFIER/$MULE_ASSETVERSION $MARKDOWNFILENAMEWITHOUTEXTENSION $MULE_ASSETPAGEMARKDOWNPATH/$MARKDOWNFILENAME)
	status=$?
	if [ $status -gt 0 ]; then
		echo Error: $RESPONSE 
	else
		echo $RESPONSE
	fi
done

if [ "$MULE_PUTASSETTAGS" = true ]; then	#Put Exchange Asset Tags
	if [ "$MULE_PYTHONSSLVERIFICATIONREQUIRED" = true ]; then
		TAGS=$(python3.7 ./python/putTagsCategories.py -a $ANYPOINT_HOST -u $ANYPOINT_USERNAME -p $ANYPOINT_PASSWORD -o $ANYPOINT_ORG -t tags -f $MULE_ASSETCONFIGFILE -i $MULE_ASSETIDENTIFIER -v $MULE_ASSETVERSION -s)
		
	else
		TAGS=$(python3.7 ./python/putTagsCategories.py -a $ANYPOINT_HOST -u $ANYPOINT_USERNAME -p $ANYPOINT_PASSWORD -o $ANYPOINT_ORG -t tags -f $MULE_ASSETCONFIGFILE -i $MULE_ASSETIDENTIFIER -v $MULE_ASSETVERSION)
	fi
	status=$?
	if [ $status -gt 0 ]; then
		echo $TAGS
		exit $status
	else
		echo $TAGS
	fi
fi

if [ "$MULE_PUTASSETCATEGORIES" = true ]; then	#Put Exchange Asset Categories
	if [ "$MULE_PYTHONSSLVERIFICATIONREQUIRED" = true ]; then
		CATEGORIES=$(python3.7 ./python/putTagsCategories.py -a $ANYPOINT_HOST -u $ANYPOINT_USERNAME -p $ANYPOINT_PASSWORD -o $ANYPOINT_ORG -t categories -f $MULE_ASSETCONFIGFILE -i $MULE_ASSETIDENTIFIER -v $MULE_ASSETVERSION -s)
	else
		CATEGORIES=$(python3.7 ./python/putTagsCategories.py -a $ANYPOINT_HOST -u $ANYPOINT_USERNAME -p $ANYPOINT_PASSWORD -o $ANYPOINT_ORG -t categories -f $MULE_ASSETCONFIGFILE -i $MULE_ASSETIDENTIFIER -v $MULE_ASSETVERSION)
	fi
	status=$?
	if [ $status -gt 0 ]; then
		echo $CATEGORIES
		exit $status
	else
		echo $CATEGORIES
	fi
fi