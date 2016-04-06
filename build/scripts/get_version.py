#!/usr/bin/env python

import os
import sys
import json
from collections import OrderedDict

def readPackageJSON(path):
	with open(path, "r") as jsonFile:
	    return json.load(jsonFile, object_pairs_hook=OrderedDict)

def getPackageVersion(baseVersion):
	buildVersion = os.environ.get('PACKAGE_VERSION')
	if buildVersion == None:
		return baseVersion
	return baseVersion + "-" + buildVersion

if __name__ == "__main__":
	if len(sys.argv) < 2:
		print "Package.json location argument is missing"
		sys.exit(2)
	data = readPackageJSON(sys.argv[1]);
	print getPackageVersion(data["version"])
