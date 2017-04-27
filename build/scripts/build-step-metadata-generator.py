#!/usr/bin/env python

import os
import subprocess
import shlex
import sys


print("Python version: " + sys.version)

def env(env_name):
    return os.environ[env_name]


def env_or_none(env_name):
    return os.environ.get(env_name)


def env_or_empty(env_name):
    result = env_or_none(env_name)
    if result is None:
        return ""
    return result

def map_and_list(func, iterable):
    result = map(func, iterable)
    if sys.version_info[0] >= 3:
        return list(result)
    return result


# process environment variables
conf_build_dir = env("CONFIGURATION_BUILD_DIR")
sdk_root = env("SDKROOT")
deployment_target_flag_name = env("DEPLOYMENT_TARGET_CLANG_FLAG_NAME")
deployment_target = env(env("DEPLOYMENT_TARGET_CLANG_ENV_NAME"))
std = env("GCC_C_LANGUAGE_STANDARD")
header_search_paths = env_or_empty("HEADER_SEARCH_PATHS")
header_search_paths_parsed = map_and_list((lambda s: "-I" + s), shlex.split(header_search_paths))
framework_search_paths = env_or_empty("FRAMEWORK_SEARCH_PATHS")
framework_search_paths_parsed = map_and_list((lambda s: "-F" + s), shlex.split(framework_search_paths))
other_cflags = env_or_empty("OTHER_CFLAGS")
other_cflags_parsed = shlex.split(other_cflags)
preprocessor_defs = env_or_empty("GCC_PREPROCESSOR_DEFINITIONS")
preprocessor_defs_parsed = map_and_list((lambda s: "-D" + s), shlex.split(preprocessor_defs, '\''))
typescript_output_folder = env_or_none("TNS_TYPESCRIPT_DECLARATIONS_PATH")
docset_platform = "iOS"
effective_platofrm_name = env("EFFECTIVE_PLATFORM_NAME")

if effective_platofrm_name is "-macosx":
    docset_platform = "OSX"
elif effective_platofrm_name is "-watchos" or effective_platofrm_name is "-watchsimulator":
    docset_platform = "watchOS"
elif effective_platofrm_name is "-appletvos" or effective_platofrm_name is "-appletvsimulator":
    docset_platform = "tvOS"
docset_path = os.path.join(os.path.expanduser("~"), "Library/Developer/Shared/Documentation/DocSets/com.apple.adc.documentation.{}.docset".format(docset_platform))
yaml_output_folder = env_or_none("TNS_DEBUG_METADATA_PATH")


def generate_metadata(arch):
    # metadata generator arguments
    generator_call = ["./objc-metadata-generator",
                      "-output-bin", "{}/metadata-{}.bin".format(conf_build_dir, arch),
                      "-output-umbrella", "{}/umbrella-{}.h".format(conf_build_dir, arch),
                      "-docset-path", docset_path]

    # optionally add typescript output folder
    if typescript_output_folder is not None:
        current_typescript_output_folder = os.path.join(typescript_output_folder, arch)
        generator_call.extend(["-output-typescript", current_typescript_output_folder])
        print("Generating TypeScript declarations in: \"{}\"".format(current_typescript_output_folder))

    # optionally add yaml output folder
    if yaml_output_folder is not None:
        current_yaml_output_folder = yaml_output_folder + "-" + arch
        generator_call.extend(["-output-yaml", current_yaml_output_folder])
        print("Generating debug metadata in: \"{}\"".format(current_yaml_output_folder))

    # clang arguments
    generator_call.extend(["Xclang",
                           "-isysroot", sdk_root,
                           "-arch", arch,
                           "-" + deployment_target_flag_name + "=" + deployment_target,
                           "-std=" + std])

    generator_call.extend(header_search_paths_parsed)  # HEADER_SEARCH_PATHS
    generator_call.extend(framework_search_paths_parsed)  # FRAMEWORK_SEARCH_PATHS
    generator_call.extend(other_cflags_parsed)  # OTHER_CFLAGS
    generator_call.extend(preprocessor_defs_parsed)  # GCC_PREPROCESSOR_DEFINITIONS

    child_process = subprocess.Popen(generator_call, stderr=subprocess.PIPE, universal_newlines=True)
    sys.stdout.flush()
    error_stream_content = child_process.communicate()[1]

    # save error stream content to file
    error_log_file = "{}/metadata-generation-stderr-{}.txt".format(conf_build_dir, arch)
    error_file = open(error_log_file, "w")
    error_file.write(error_stream_content)
    error_file.close()

    if child_process.returncode != 0:
        print("Error: Unable to generate metadata for {}.".format(arch))
        print(error_stream_content)
        sys.exit(1)


for arch in env("ARCHS").split():
    print("Generating metadata for " + arch)
    generate_metadata(arch)