#!/bin/bash

deployApp () {
  echo "Start Deploy App"
  return $1
}


function getAppsList(){
    local offset=0
    local limit=100
    local apps_in_page=1
    local appsJson=""

    if [[ -z $APPS_LIST ]]; then 
        APPS_LIST="[]"
    fi 

    while [[ ${apps_in_page} -gt 0 ]]; do 
        appsJson="$(anypoint-cli runtime-mgr cloudhub-application list -o json | jq .)"
        echo "$appsJson"
	apps_in_page=$(echo "$appsJson" | jq . | jq length)
	 echo "Apps in Page"
	 echo "${apps_in_page}"
        if [[ ${apps_in_page} -gt 0 ]]; then 
            APPS_LIST=$(echo "$APPS_LIST" | jq ". += $appsJson")
        fi
        ((offset=$offset+$limit))
    done
}

deployApp
getAppsList
echo $1
