#!/bin/bash
export ANYPOINT_PROFILE="connAppProfile"

deployApp () {
  echo "Start Deploy App"
  return $1
}

testApp(){
anypoint-cli
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
        apps_in_page=$(echo "$appsJson" | jq . | jq length)
        if [[ ${apps_in_page} -gt 0 ]]; then 
            APPS_LIST=$(echo "$APPS_LIST" | jq ". += $appsJson")
        fi
        ((offset=$offset+$limit))
    done
}

deployApp
testApp
echo $1
