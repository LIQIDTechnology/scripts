echo Starting Asset Page verification in Anypoint Exchange...

API_PATH=$1
source $API_PATH/config.sh

source ./common.sh

VARS=( "ANYPOINT_HOST" "ANYPOINT_USERNAME" "ANYPOINT_PASSWORD" "ANYPOINT_ORG" "MULE_ASSETIDENTIFIER" "MULE_ASSETVERSION" "MULE_CHECKASSETTAGS" "MULE_CHECKASSETCATEGORIES" "MULE_ASSETVERIFICATIONCONFIGFILE" "MULE_APIVERSION" "MULE_PYTHONSSLVERIFICATIONREQUIRED" )

checkEnvVariables VARS

PAGES=$(yq r "$MULE_ASSETVERIFICATIONCONFIGFILE" Pages)
onErrorExit $? "Error while parsing yml file $MULE_ASSETVERIFICATIONCONFIGFILE : $PAGES"

DEBUG "Checking this asset has the following pages: $PAGES"

ASSETPAGES=$(anypoint-cli exchange asset page list $MULE_ASSETIDENTIFIER/$MULE_ASSETVERSION | sed 's/\x1b\[[0-9;]*m//g')
onErrorExit $? "Error while listing Exchange pages: $ASSETPAGES"
ASSETPAGESCOUNT=$(echo -n "$ASSETPAGES" | grep -c '^')
DEBUG "Asset pages found in Exchange: $ASSETPAGES"

if [ $ASSETPAGESCOUNT -gt 2 ]; then #First 2 lines are header lines in the ASSETPAGES variable
	{
		read
		read
		currPage=0
		while read -r line
		do
			DEBUG "ASSET PAGE NAME FROM PCE: $line"
			ASSETPAGESARRAY[$currPage]=$(echo "$line")
			((currPage++))
		done
	}	< <(printf '%s\n' "$ASSETPAGES")
else
	onErrorExit 1 "No Asset Pages created for asset [$MULE_ASSETIDENTIFIER]. Please create the following asset pages:  $PAGES"
fi

IFS=","
countMissingPages=0
for PAGE in $PAGES
do
	ASSETPAGEFOUND=false
	for ASSETPAGE in "${ASSETPAGESARRAY[@]}"
	do
		DEBUG "Checking that '$PAGE'  == '$ASSETPAGE'"
		if [ $PAGE ==  $ASSETPAGE ]; then
			DEBUG "Asset page found!"
			ASSETPAGEFOUND=true
			break	
		fi
	done
	if [ "$ASSETPAGEFOUND" = false ]; then
		DEBUG "Asset page '$PAGE' could not be found..."
		MISSINGASSETPAGES[$countMissingPages]=$(echo $PAGE)
		((countMissingPages++))
	fi
done

if [ ${#MISSINGASSETPAGES[@]} -gt 0 ]; then	#Checking the lengt of the array
	onErrorExit 1 "The following pages are missing from the Exchange asset: '${MISSINGASSETPAGES[*]}'"	#Printing contents of the array
else
	INFO "All asset pages available"
fi

if [ "$MULE_CHECKASSETTAGS" = true ]; then	#Check Exchange Asset Tags
	INFO "Checking asset's tags"
	if [ "$MULE_PYTHONSSLVERIFICATIONREQUIRED" = true ]; then
		TAGVERIFICATION=$(python3.7 ./python/verifyTagsCategories.py -a $ANYPOINT_HOST -u $ANYPOINT_USERNAME -p $ANYPOINT_PASSWORD -o $ANYPOINT_ORG -c tags -f $MULE_ASSETVERIFICATIONCONFIGFILE -i $MULE_ASSETIDENTIFIER -v $MULE_ASSETVERSION -pav $MULE_APIVERSION -s)
	else
		TAGVERIFICATION=$(python3.7 ./python/verifyTagsCategories.py -a $ANYPOINT_HOST -u $ANYPOINT_USERNAME -p $ANYPOINT_PASSWORD -o $ANYPOINT_ORG -c tags -f $MULE_ASSETVERIFICATIONCONFIGFILE -i $MULE_ASSETIDENTIFIER -v $MULE_ASSETVERSION -pav $MULE_APIVERSION)
	fi
	onErrorExit $? $TAGVERIFICATION
	echo $TAGVERIFICATION
fi

if [ "$MULE_CHECKASSETCATEGORIES" = true ]; then	#Check Exchange Asset Categories
	INFO "Check asset's categories"
	if [ "$MULE_PYTHONSSLVERIFICATIONREQUIRED" = true ]; then
		CATEGORYVERIFICATION=$(python3.7 ./python/verifyTagsCategories.py -a $ANYPOINT_HOST -u $ANYPOINT_USERNAME -p $ANYPOINT_PASSWORD -o $ANYPOINT_ORG -c categories -f $MULE_ASSETVERIFICATIONCONFIGFILE -i $MULE_ASSETIDENTIFIER -v $MULE_ASSETVERSION -pav $MULE_APIVERSION -s)
	else
		CATEGORYVERIFICATION=$(python3.7 ./python/verifyTagsCategories.py -a $ANYPOINT_HOST -u $ANYPOINT_USERNAME -p $ANYPOINT_PASSWORD -o $ANYPOINT_ORG -c categories -f $MULE_ASSETVERIFICATIONCONFIGFILE -i $MULE_ASSETIDENTIFIER -v $MULE_ASSETVERSION -pav $MULE_APIVERSION)
	fi
	onErrorExit $? $CATEGORYVERIFICATION
	echo $CATEGORYVERIFICATION
fi