#!/usr/bin/env python

import json
import os
import sys

import get_version

if len(sys.argv) < 2:
    print "Package.json location argument is missing"
    sys.exit(2)


def get_commit_sha():
    commit_sha = os.environ.get('GIT_COMMIT')
    if commit_sha is None:
        return os.popen("git rev-parse HEAD").read().replace("\n", "")


def update_package_version():
    data = get_version.read_package_json(sys.argv[1])
    data["version"] = get_version.get_package_version(data["version"])
    commit_sha = get_commit_sha()
    if commit_sha:
        data["repository"]["url"] += "/commit/" + commit_sha

    with open(sys.argv[1], "w") as jsonFile:
        jsonFile.write(json.dumps(data, indent=2))


if __name__ == "__main__":
    update_package_version()
