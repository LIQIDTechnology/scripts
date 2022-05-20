## Staging server details

export ANYPOINT_ENV=STAGING

#Environment Variables required to switch off SSL Verification in Python
export MULE_RUNTIMEVERSION=4.4.0
export MULE_DEPLOYMENTTYPE=cloudhub

#Cloudhub Deployment Variables
export MULE_CLOUDHUBWORKERS=1
export MULE_CLOUDHUBWORKERSIZE=0.1
export MULE_CLOUDHUBREGION=eu-central-1
#export MULE_CLOUDHUBPROPERTIES="--property anypoint.platform.client_id:XXXXXX --property anypoint.platform.client_secret:YYYYYY"