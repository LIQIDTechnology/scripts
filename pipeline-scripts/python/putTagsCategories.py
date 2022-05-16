# install missing libraries on Ubuntu for Python3.7: sudo python3.7 -m pip install <library_name>
import argparse, ruamel.yaml, mulesoft, json, os

parser = argparse.ArgumentParser()
parser.add_argument("-a", "--anypointHost", help="Anypoint Platform Host")
parser.add_argument("-u", "--username", help="Username to connect platform APIs")
parser.add_argument("-p", "--password", help="Password to connect platform APIs")
parser.add_argument("-o", "--organization", help="Organization Id")
parser.add_argument("-t", "--type", help="Type to put: Tags or Categories")
parser.add_argument("-f", "--configFile", help="Config file path")
parser.add_argument("-i", "--assetId", help="Exchange Asset Identifier")
parser.add_argument("-v", "--assetVersion", help="Exchange Asset Version")
parser.add_argument("-s", "--sslVerification", action='store_true', default=False, help="Is SSL Verification Required")

args = parser.parse_args()

if args.type is None or args.type not in ("tags", "categories"):
    raise Exception("Type should be 'tags' or 'categories'")
if args.configFile is None:
    raise Exception("Please provide config file path")

with open(args.configFile) as file:
    yaml = ruamel.yaml.YAML().load(file)


def getTagsFromConfig():
    if 'Tags' not in yaml:
        raise Exception("Please provide the tags to check")
    return yaml["Tags"]


def getCategoriesFromConfig():
    if 'Categories' not in yaml:
        raise Exception("Please provide the Categories to check")
    return yaml["Categories"]


def getCategoryValueFromConfig(assetCategory):
    return yaml['Categories'][assetCategory]

try:
    credentials = '{ "username" : "%s", "password" : "%s" }' % (args.username, args.password)
    access_token = mulesoft.getBearerToken(args.anypointHost, credentials, args.sslVerification)
    headers = {"Authorization":  access_token}
    organizationId = mulesoft.getOrganisationId(args.anypointHost, args.organization, access_token, args.sslVerification)
except Exception as e:
    print("Error: " + str(e))
    exit(1)


if args.type == "tags":
    try:
        tagsList = getTagsFromConfig().split(",")
        dataList = []
        for tag in tagsList:
            data = dict()
            data['value'] = tag
            dataList.append(data)
        json_data = json.dumps(dataList)
        mulesoft.putPortalTags(args.anypointHost, organizationId, args.assetId, args.assetVersion, access_token,
                               json_data, args.sslVerification)
        print("Successfully created the tags:"+str(tagsList))
        exit(0)
    except Exception as e:
        print("Error updating the portal tags with error: "+str(e))
        exit(1)

if args.type == "categories":
    try:
        categoriesMap = getCategoriesFromConfig()
        categoriesList = list(categoriesMap.keys())
        for category in categoriesList:
            categoryValue = getCategoryValueFromConfig(category).split(",")
            data = dict()
            data['tagValue'] = categoryValue
            json_data = json.dumps(data)
            mulesoft.putPortalCategories(args.anypointHost, organizationId, args.assetId, args.assetVersion, category,
                                         json_data, access_token, args.sslVerification)
        print("Successfully created the categories:"+str(categoriesMap))
        exit(0)
    except Exception as e:
        print("Error updating the portal categories with error: "+str(e))
        exit(1)
