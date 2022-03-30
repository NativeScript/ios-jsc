#!/usr/bin/env python

import os
import shlex
import subprocess
import sys

print("Python version: " + sys.version)

def str2bool(v):
  return v.lower() in ("yes", "y", "true", "t", "1")

def env(env_name):
    return os.environ[env_name]


def env_or_none(env_name):
    return os.environ.get(env_name)


def env_or_empty(env_name):
    result = env_or_none(env_name)
    if result is None:
        return ""
    return result

def env_bool(env_name):
    return str2bool(env_or_empty(env_name))

def map_and_list(func, iterable):
    result = map(func, iterable)
    if sys.version_info[0] >= 3:
        return list(result)
    return result


# process environment variables
effective_platofrm_name = env("EFFECTIVE_PLATFORM_NAME")
docset_platform = "iOS"
default_deployment_target_flag_name = "-mios-simulator-version-min"
default_deployment_target_clang_env_name = "IPHONEOS_DEPLOYMENT_TARGET"
if effective_platofrm_name is "-macosx":
    docset_platform = "OSX"
    default_deployment_target_flag_name = "-mmacosx-version-min"
    default_deployment_target_clang_env_name = "MACOSX_DEPLOYMENT_TARGET"
elif effective_platofrm_name is "-watchos":
    docset_platform = "watchOS"
    default_deployment_target_flag_name = "-mwatchos-version-min"
    default_deployment_target_clang_env_name = "WATCHOS_DEPLOYMENT_TARGET"
elif effective_platofrm_name is "-watchsimulator":
    docset_platform = "watchOS"
    default_deployment_target_flag_name = "-mwatchos-simulator-version-min"
    default_deployment_target_clang_env_name = "WATCHOS_DEPLOYMENT_TARGET"
elif effective_platofrm_name is "-appletvos":
    docset_platform = "tvOS"
    default_deployment_target_flag_name = "-mappletvos-version-min"
    default_deployment_target_clang_env_name = "APPLETVOS_DEPLOYMENT_TARGET"
elif effective_platofrm_name is "-appletvsimulator":
    docset_platform = "tvOS"
    default_deployment_target_flag_name = "-mappletvsimulator-version-min"
    default_deployment_target_clang_env_name = "APPLETVOS_DEPLOYMENT_TARGET"
elif effective_platofrm_name is "-iphoneos":
    default_deployment_target_flag_name = "-miphoneos-version-min"

conf_build_dir = env("CONFIGURATION_BUILD_DIR")
sdk_root = env("SDKROOT")
src_root = env("SRCROOT")
deployment_target_flag_name = env_or_empty("DEPLOYMENT_TARGET_CLANG_FLAG_NAME") or default_deployment_target_flag_name
deployment_target = env(env_or_empty("DEPLOYMENT_TARGET_CLANG_ENV_NAME") or default_deployment_target_clang_env_name)
std = env("GCC_C_LANGUAGE_STANDARD")
header_search_paths = env_or_empty("HEADER_SEARCH_PATHS")
header_search_paths_parsed = map_and_list((lambda s: "-I" + s), shlex.split(header_search_paths))
framework_search_paths = env_or_empty("FRAMEWORK_SEARCH_PATHS")
framework_search_paths_parsed = map_and_list((lambda s: "-F" + s), shlex.split(framework_search_paths))
other_cflags = env_or_empty("OTHER_CFLAGS")
other_cflags_parsed = shlex.split(other_cflags)
enable_modules = env_bool("CLANG_ENABLE_MODULES")
preprocessor_defs = env_or_empty("GCC_PREPROCESSOR_DEFINITIONS")
preprocessor_defs_parsed = map_and_list((lambda s: "-D" + s), shlex.split(preprocessor_defs, '\''))
typescript_output_folder = env_or_none("TNS_TYPESCRIPT_DECLARATIONS_PATH")




docset_path = os.path.join(os.path.expanduser("~"),
                           "Library/Developer/Shared/Documentation/DocSets/com.apple.adc.documentation.{}.docset"
                           .format(docset_platform))
yaml_output_folder = env_or_none("TNS_DEBUG_METADATA_PATH")
strict_includes = env_or_none("TNS_DEBUG_METADATA_STRICT_INCLUDES")


def save_stream_to_file(filename, stream):
    f = open(filename, "w")
    f.write(stream)
    f.close()


# noinspection PyShadowingNames
def generate_metadata(arch):
    # metadata generator arguments
    generator_call = ["./objc-metadata-generator", "-verbose",
                      "-output-bin", "{}/metadata-{}.bin".format(conf_build_dir, arch),
                      "-output-umbrella", "{}/umbrella-{}.h".format(conf_build_dir, arch),
                      "-docset-path", docset_path]

    if strict_includes is not None:
        generator_call.extend(["-strict-includes={}".format(strict_includes)])

    # optionally add typescript output folder
    if typescript_output_folder is not None:
        current_typescript_output_folder = os.path.join(typescript_output_folder, arch)
        generator_call.extend(["-output-typescript", current_typescript_output_folder])
        print("Generating TypeScript declarations in: \"{}\"".format(current_typescript_output_folder))

    # optionally add yaml output folder
    current_yaml_output_folder = None
    if yaml_output_folder is not None:
        current_yaml_output_folder = yaml_output_folder + "-" + arch
        generator_call.extend(["-output-yaml", current_yaml_output_folder])
        print("Generating debug metadata in: \"{}\"".format(current_yaml_output_folder))

    whitelist_file_name = os.path.join(src_root, "whitelist.mdg")
    if os.path.exists(whitelist_file_name):
      generator_call.extend(["--whitelist-modules-file", whitelist_file_name])

    blacklist_file_name = os.path.join(src_root, "blacklist.mdg")
    if os.path.exists(blacklist_file_name):
      generator_call.extend(["--blacklist-modules-file", blacklist_file_name])

    # clang arguments
    generator_call.extend(["Xclang",
                           "-isysroot", sdk_root,
                           "-" + deployment_target_flag_name + "=" + deployment_target,
                           "-std=" + std])

    if env_or_empty("IS_UIKITFORMAC").capitalize() is "YES":
      generator_call.extend(["-arch", arch])
    else:
      generator_call.extend(["-target", "{}-apple-ios13.0-macabi".format(arch)])

    generator_call.extend(header_search_paths_parsed)  # HEADER_SEARCH_PATHS
    generator_call.extend(framework_search_paths_parsed)  # FRAMEWORK_SEARCH_PATHS
    generator_call.extend(other_cflags_parsed)  # OTHER_CFLAGS
    generator_call.extend(preprocessor_defs_parsed)  # GCC_PREPROCESSOR_DEFINITIONS

    if enable_modules:
        # -I. is needed for includes coming from clang's lib/clang/<version>/include/ directory when parsing modules
        generator_call.extend(["-I.", "-fmodules"])

    child_process = subprocess.Popen(generator_call, stderr=subprocess.PIPE, universal_newlines=True)
    sys.stdout.flush()
    error_stream_content = child_process.communicate()[1]

    # save error stream content to file
    error_log_file = "{}/metadata-generation-stderr-{}.txt".format(conf_build_dir, arch)
    print("Saving metadata generation's stderr stream to: {}".format(error_log_file))
    save_stream_to_file(error_log_file, error_stream_content)
    if current_yaml_output_folder is not None:
      yaml_dir_error_log_file = "{}/metadata-generation-stderr.txt".format(current_yaml_output_folder)
      print("Copying metadata stderr stream to: {}".format(yaml_dir_error_log_file))
      save_stream_to_file(yaml_dir_error_log_file, error_stream_content)

    if child_process.returncode != 0:
        print("Error: Unable to generate metadata for {}.".format(arch))
        print(error_stream_content)
        sys.exit(1)


for arch in env("ARCHS").split():
    print("Generating metadata for " + arch)
    generate_metadata(arch)