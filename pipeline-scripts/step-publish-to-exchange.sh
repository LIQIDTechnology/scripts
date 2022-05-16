#!/bin/bash

source ./mule-ci-build-step-set-env.sh

./uploadExchangeAsset.sh

./createExchangeAssetPage.sh

./verifyAssetPages.sh





 
