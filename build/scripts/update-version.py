#!/usr/bin/env python

import os
import sys
import json
import get_version

if len(sys.argv) < 2:
	print "Package.json location argument is missing"
	sys.exit(2)

def getCommitSHA():
	commitSHA = os.environ.get('GIT_COMMIT');
	if commitSHA == None:
		return  os.popen("git rev-parse HEAD").read().replace("\n", "");
		
def updatePackageVersion():
	data = get_version.readPackageJSON(sys.argv[1])
	data["version"] = get_version.getPackageVersion(data["version"])
	commitSHA = getCommitSHA()
	if commitSHA:
		data["repository"]["url"] += "/commit/" + commitSHA

	with open(sys.argv[1], "w") as jsonFile:
	    jsonFile.write(json.dumps(data, indent=2))

if __name__ == "__main__":
	updatePackageVersion()
