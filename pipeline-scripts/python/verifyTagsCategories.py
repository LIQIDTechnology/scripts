# install missing libraries on Ubuntu for Python3.7: sudo python3.7 -m pip install <library_name>
import argparse, ruamel.yaml, mulesoft


parser = argparse.ArgumentParser()
parser.add_argument("-a", "--anypointHost", help="Anypoint Platform Host")
parser.add_argument("-u", "--username", help="Username to connect platform APIs")
parser.add_argument("-p", "--password", help="Password to connect platform APIs")
parser.add_argument("-o", "--organization", help="Organization Id")
parser.add_argument("-c", "--checkType", help="Type of check: Tags or Categories")
parser.add_argument("-f", "--configFile", help="Config file path")
parser.add_argument("-i", "--assetId", help="Exchange Asset Identifier")
parser.add_argument("-v", "--assetVersion", help="Exchange Asset Version")
parser.add_argument("-pav", "--productAPIVersion", help="Product API Version")
parser.add_argument("-s", "--sslVerification", action='store_true', default=False, help="Is SSL Verification Required")

args = parser.parse_args()

if args.checkType is None or args.checkType not in ("tags", "categories"):
    print("Check Type should be 'tags' or 'categories'")
    exit(1)
if args.configFile is None:
    print("Please provide config file path")
    exit(1)

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


def getExchangeAssetTags(assetDetailsJSON, APIVersion, assetId, assetVersion):
    assetTags = []
    if assetDetailsJSON is not None:
        productAPIVersions=assetDetailsJSON['productAPIVersions']
        if productAPIVersions is not None:
            for productAPIVersion in productAPIVersions:
                if productAPIVersion['productAPIVersion'] == APIVersion:
                    versions = productAPIVersion['versions']
                    if versions is not None:
                        for version in versions:
                            if version['assetId'] == assetId and version['version'] == assetVersion:
                                labels=version['labels']
                                if labels is not None:
                                    for label in labels:
                                        if label['tagType'] == "label":
                                            assetTags.append(label['value'])
                                break
                    break
    return assetTags


def getExchangeAssetCategories(assetDetailsJSON):
    assetCategories = []
    if assetDetailsJSON is not None:
        categories = assetDetailsJSON['categories']
        if categories is not None:
            for category in categories:
                assetCategories.append(category['key'])
            return assetCategories


def getExchangeAssetCategoryValue(assetDetailsJSON, assetCategory):
    assetCategoryValue = []
    if assetDetailsJSON is not None:
        categories = assetDetailsJSON['categories']
        if categories is not None:
            for category in categories:
                if category['key'] == assetCategory:
                    assetCategoryValue = category['value']
                    break
    return assetCategoryValue


def compareLists(list1, list2):
    return [x for x in list2 if x.lower() not in [x.lower() for x in list1]]


try:
    credentials = '{ "username" : "%s", "password" : "%s" }' % (args.username, args.password)
    access_token = mulesoft.getBearerToken(args.anypointHost, credentials, args.sslVerification)
    headers = {"Authorization":  access_token}
    organizationId = mulesoft.getOrganisationId(args.anypointHost, args.organization, access_token, args.sslVerification)
    assetDetailsJSON = mulesoft.getAssetsDetails(args.anypointHost, organizationId, args.assetId, args.productAPIVersion,
                                                 access_token, args.sslVerification)
except Exception as e:
    print("Error: " + str(e))
    exit(1)

if args.checkType == "tags":
    try:
        tagsList = getTagsFromConfig().split(",")
        assetTagsList = getExchangeAssetTags(assetDetailsJSON, args.productAPIVersion, args.assetId, args.assetVersion)
        tagDiff = compareLists(assetTagsList, tagsList)
        if len(tagDiff) > 0:
            print("Missing tags in Exchange Asset: " + str(tagDiff))
            exit(1)
        else:
            print("All tags present in the Exchange Asset")
            exit(0)
    except Exception as e:
        print("Error checking portal tags with error: "+str(e))
        exit(1)


if args.checkType == "categories":
    try:
        results = []
        categoriesMap = getCategoriesFromConfig()
        categoriesList = list(categoriesMap.keys())
        assetCategoriesList = getExchangeAssetCategories(assetDetailsJSON)
        categoriesDiff = compareLists(assetCategoriesList, categoriesList)
        if len(categoriesDiff) > 0:
            result = list()
            result.append("Missing Categories in Exchange Asset: " + str(categoriesDiff))
            results.append(result)
        for assetCategory in assetCategoriesList:
            categoryValueFromConfigList = getCategoryValueFromConfig(assetCategory).split(",")
            categoryValueFromExchangeAsset = getExchangeAssetCategoryValue(assetDetailsJSON, assetCategory)
            categoryValueDiff = compareLists(categoryValueFromExchangeAsset, categoryValueFromConfigList)
            if len(categoryValueDiff) > 0:
                result = list()
                result.append("Missing values for category: " + assetCategory + " are: " + str(categoryValueDiff))
                results.append(result)
        if len(results) > 0:
            print(str(results))
            exit(1)
        else:
            print("All Categories and Category Values present in Exchange Asset")
            exit(0)
    except Exception as e:
        print("Error checking portal categories with error: "+str(e))
        exit(1)
