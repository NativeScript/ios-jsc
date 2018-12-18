#!/usr/bin/env python

import json
import os
import sys
from collections import OrderedDict


def read_package_json(path):
    with open(path, "r") as jsonFile:
        return json.load(jsonFile, object_pairs_hook=OrderedDict)


def get_package_version(base_version):
    build_version = os.environ.get('PACKAGE_VERSION')
    if build_version is None:
        return base_version
    return base_version + "-" + build_version


def get_framework_version(base_version):
    return base_version.split("-")[0]


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "Package.json location argument is missing"
        sys.exit(2)
    data = read_package_json(sys.argv[1])
    print "{};{};{}".format(data["version"],
                            get_package_version(data["version"]),
                            get_framework_version(data["version"]))
