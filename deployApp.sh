#!/bin/bash

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
