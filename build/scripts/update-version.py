#!/usr/bin/env python

import os
import sys
import json
from collections import OrderedDict

if len(sys.argv) < 2:
	print "Package.json location argument is missing"
	sys.exit(2)

def getCommitSHA():
	commitSHA = os.environ.get('GIT_COMMIT');
	if commitSHA == None:
		return  os.popen("git rev-parse HEAD").read().replace("\n", "");
		
def getPackageVersion(baseVersion):
	buildVersion = os.environ.get('PACKAGE_VERSION')
	if buildVersion == None:
		return baseVersion
	return baseVersion + "-" + buildVersion

def updatePackageVersion(data):
	data["version"] = getPackageVersion(data["version"])
	commitSHA = getCommitSHA()
	if commitSHA:
		data["repository"]["url"] += "/commit/" + commitSHA

with open(sys.argv[1], "r") as jsonFile:
    data = json.load(jsonFile, object_pairs_hook=OrderedDict)    

updatePackageVersion(data)

with open(sys.argv[1], "w") as jsonFile:
    jsonFile.write(json.dumps(data, indent=2))
