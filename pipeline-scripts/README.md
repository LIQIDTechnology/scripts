# Anypoint Pipeline Scipts

## Requirements

![ed30b1b7-af4f-4f0f-8492-203c7a07e71a-ADVSAPI.png](https://blogs.mulesoft.com/wp-content/uploads/2012/05/mulesoft-logo-final.png)

In order to run anypoint scripts it's Linux only supported.

Required tools:

* jq - json query tool, yum install | apt get install 
* yq - yaml query tool, to install

```shell
wget https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64
chmod u+x yq_linux_amd64
mv ./yq_linux_amd64 /usr/bin/yq
```
* anypoint-cli - installation tools https://docs.mulesoft.com/runtime-manager/anypoint-platform-cli#installation


## Script Files
* createExchangeAssetPage.sh - Starting Asset Page Creation in Anypoint Exchange
* importExchangeAssetToAPIManager.sh - Starting Exchange Asset Import to Anypoint API Manager
* uploadExchangeAsset.sh - Starting Asset deployment in Anypoint
* verifyAssetPages.sh - Starting Asset Page verification in Anypoint Exchange


## Pipeline scipts files
Several predefined pipelines are preconfigured to be used as samples:
* step-publish-to-exchange.sh

## Usage and instruction
* sudo /bin/bash ./createExchangeAssetPage.sh ../examples/FootfallExperienceACM
```
Command will only create Page to a given exchange assets.
```
* sudo /bin/bash ./uploadExchangeAsset.sh ../examples/FootfallExperienceACM
```
Command will upload assets to Design center and then published to exchange. 
It required a new version if API specification change else it will overwrite old version.
```
* sudo /bin/bash ./verifyAssetPages.sh ../examples/FootfallExperienceACM
```
Command will verify assets page in exchange and will apply the desired tags.
```
