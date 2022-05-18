#!/bin/bash
export ANYPOINT_PROFILE="connAppProfile"

deployApp () {
  echo "Start Deploy App"
  return $1
}

testApp(){
anypoint-cli
}


deployApp
testApp
echo $1
