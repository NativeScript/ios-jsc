#!/usr/bin/env python

import getopt
import sys


def main(argv):
    usage = 'Usage: ' \
            'generate_typescript_interfaces.py ' \
            '--inspector-scripts-path <path to JavaScriptCore/inspector/scripts> ' \
            '--combined-domains-path <path to CombinedDomains.json> ' \
            '--output-dir <result directory path>'

    if len(argv) != 6:
        print usage
        sys.exit(2)

    inspector_scripts_path = ''
    combined_domains_path = ''
    output_dir = ''
    try:
        opts, args = getopt.getopt(argv, "h",
                                   ["help",
                                    "inspector-scripts-path=",
                                    "combined-domains-path=",
                                    "output-dir="])
    except getopt.GetoptError:
        print usage
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print usage
            sys.exit()
        elif opt == "--inspector-scripts-path":
            inspector_scripts_path = arg
        elif opt == "--combined-domains-path":
            combined_domains_path = arg
        elif opt == "--output-dir":
            output_dir = arg

    sys.path.append(inspector_scripts_path)

    from generate import generate
    generate(combined_domains_path, output_dir)


if __name__ == "__main__":
    main(sys.argv[1:])
