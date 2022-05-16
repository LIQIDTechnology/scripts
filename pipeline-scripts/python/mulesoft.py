# install missing libraries on Ubuntu for Python3.7: sudo python3.7 -m pip install <library_name>
import requests, json


def getBearerToken(anypointHost, credentials, verification):
    loginurl = "https://"+anypointHost+"/accounts/login"
    headers = { "Content-Type" : "application/json" }
    response = requests.post(loginurl, headers=headers, data=credentials, verify=verification)
    if response.ok:
        access_token = "bearer " + str(response.json()['access_token'])
        return access_token
    else:
        raise Exception("Authentication Failed")


def getOrganisationId(anypointHost, organizationName, authorisation, verification):
    meUrl = "https://"+anypointHost+"/accounts/api/me"
    headers = {"Authorization": authorisation}
    response = requests.get(meUrl, headers=headers, verify=verification)
    if response.ok:
        memberOfOrganizations = response.json()['user']['memberOfOrganizations']
        organizationId=""
        for memberOfOrganization in memberOfOrganizations:
            if memberOfOrganization['name'] == organizationName:
                organizationId = memberOfOrganization['id']
                break
        return organizationId
    else:
        raise Exception("Unable to get Org_id: "+str(response.status_code) + "-" + response.text)


def getAssetsDetails(anypointHost, groupId, assetId, productAPIVersion, authorisation, verification):
    assetUrl = "https://"+anypointHost+"/exchange/api/v1/assets/"+groupId + "/" + assetId + "/productApiVersion/" + productAPIVersion
    #assetUrl = "https://"+anypointHost+"/exchange/api/v1/assets/" + groupId + "/" + assetId + "/versionGroups/" + productAPIVersion
    headers = {"Authorization":  authorisation}
    response = requests.get(assetUrl, headers=headers, verify=verification)
    if response.ok:
        json = response.json()
        return json
    else:
        raise Exception('Unable to find asset id in Exchange: '+str(response.status_code) + "-" + response.text)


def putPortalTags(anypointHost, org_id, asset_id, version, access_token, tags, verification):
    url = "https://"+anypointHost+"/exchange/api/v1/organizations/%s/assets/%s/%s/%s/tags" % (org_id, org_id, asset_id, str(version))
    headers = {"Authorization" : access_token, "Content-Type" : "application/json"}
    tags = requests.put(url=url, headers=headers, data=tags, verify=verification)
    if tags.ok:
        return tags.text
    else:
        raise Exception(str(tags.status_code) + "-" + tags.text)
        # print(url)


def putPortalCategories(anypointHost, org_id, asset_id, version, tag_key, category, access_token, verification):
    url = "https://"+anypointHost+"/exchange/api/v1/organizations/%s/assets/%s/%s/%s/tags/categories/%s" % (org_id, org_id, asset_id, str(version), tag_key)
    headers = {"Authorization": access_token, "Content-Type" : "application/json"}
    categories = requests.put(url=url, headers=headers, data=category, verify=verification)
    if categories.ok:
        return json.loads(categories.text)
    else:
        print(url)
        raise Exception(str(categories.status_code) + "-" + categories.text)
