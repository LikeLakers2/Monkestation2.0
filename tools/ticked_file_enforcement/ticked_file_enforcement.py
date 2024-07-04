import fnmatch
import functools
import glob
import io
import itertools
import json
import os
import pathlib
import sys

# simple way to check if we're running on github actions, or on a local machine
on_github = os.getenv("GITHUB_ACTIONS") == "true"

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def blue(text):
    return "\033[34m" + str(text) + "\033[0m"

def yellow(text):
    return "\033[33m" + str(text) + "\033[0m"

def post_ok(string):
    print(green(f"[{includes_file}]: " + string))

def post_error(string):
    print(red(f"[{includes_file}]: " + string))
    if on_github:
        print(f"::error file={includes_file},title=Ticked File Enforcement::{string}")

def post_notice(string):
    print(blue(f"[{includes_file}]: " + string))
    if on_github:
        print(f"::notice file={includes_file},title=Ticked File Enforcement::{string}")

def post_warn(string):
    print(yellow(f"[{includes_file}]: " + string))
    if on_github:
        print(f"::warning file={includes_file},title=Ticked File Enforcement::{string}")

def perform_exit():
    if on_github:
        print(f"::endgroup::")
    sys.exit(1)

### BEGIN SCHEMA ###
# TODO: Have this script take in a file path, but still take in STDIN if the file path == "-"
schema = json.load(sys.stdin)

# (String: File path) The file that we want to take includes from
includes_file = pathlib.Path(schema["includes_file"])

# (String: Directory path) The base directory from which to collect file paths that we want to
# ensure are included in `includes_file`. Any files in `includes_file` that do not come from this
# directory are ignored.
#
# This directory must be the same directory as where `includes_file` is, or a subdirectory.
base_scanning_directory = pathlib.Path(schema["base_scanning_directory"])

# (Boolean) If we should consider the files from subdirectories of `base_scanning_directory`, when
# generating a list of files that should be within `includes_file`.
check_subdirectories = schema["check_subdirectories"]

# (Array of strings: File pathname patterns) File path patterns, relative to
# `base_scanning_directory` that are intentionally not included in `includes_file`. It is NOT an
# error for a file matching one of these patterns to be included in `includes_file`, but we will
# warn regardless.
exempt_include_globs = schema["exempt_include_globs"]

# (Array of strings: File pathname patterns) File path patterns, relative to
# `base_scanning_directory`, that are not allowed to be included in `includes_file`. It is an error
# for a file matching one of these patterns to be included in `includes_file`.
forbidden_include_globs = schema["forbidden_include_globs"]
### END SCHEMA ###

### BEGIN PROCESSING ###
if on_github:
    print(f"::group::Ticked File Enforcement [{includes_file}]")
print(f"Processing `{includes_file}`...")

# A marker to denote if Ticked File Enforcement has failed. We'll continue processing and print out
# as much as we can (to help avoid requiring multiple runs), but at the end we will denote that
# Ticked File Enforcement has found errors.
tfe_has_failed = False

# Before anything else, ensure our schema is even valid.
## The includes file must point to an existing file.
if not includes_file.is_file():
    post_error(f"The includes_file key does not point to an existing file.")
    perform_exit()
## The base scanning directory must point to an existing directory.
if not base_scanning_directory.is_dir():
    post_error(f"The base scanning directory key `{base_scanning_directory}` does not point to an existing directory.")
    perform_exit()
## The base scanning directory must be the same directory as where `includes_file` is, or a
## subdirectory.
if not base_scanning_directory.is_relative_to(includes_file.parent):
    post_error(f"The base scanning directory key `{base_scanning_directory}` must be the directory in which the includes file resides, or a subdirectory of that directory.")
    perform_exit()

# Process the exempt include globs, to create a list of files that are intentionally unincluded.
def process_exempt_include_globs():
    files_matched = set()
    files_matched_multiple_times = set()
    for exempt_include_glob in exempt_include_globs:
        matched_any_files = False
        file_list = base_scanning_directory.glob(exempt_include_glob)
        for file in file_list:
            matched_any_files = True
            if file in files_matched:
                files_matched_multiple_times.add(file)
                continue
            files_matched.add(file)
        if not matched_any_files:
            post_warn(f"The exempt include glob `{exempt_include_glob}` does not match any files.")

    for file in files_matched_multiple_times:
        post_warn(f"The file `{file}` was matched by multiple exempt include globs.")

    return files_matched

files_exempt_from_include = process_exempt_include_globs()

# Process the forbidden include globs, to create a list of files that are intentionally unincluded
# AND should never be included.
def process_forbidden_include_globs():
    files_matched = set()
    files_matched_multiple_times = set()
    for forbidden_include_glob in forbidden_include_globs:
        matched_any_files = False
        file_list = base_scanning_directory.glob(forbidden_include_glob)
        for file in file_list:
            matched_any_files = True
            if file in files_matched:
                files_matched_multiple_times.add(file)
                continue
            files_matched.add(file)
        if not matched_any_files:
            post_warn(f"The forbidden include glob `{forbidden_include_glob}` does not match any files.")

    for file in files_matched_multiple_times:
        post_warn(f"The file `{file}` was matched by multiple forbidden include globs.")

    return files_matched

files_forbidden_from_include = process_forbidden_include_globs()

# If any files from the above sets match, give out a warning.
files_forbidden_and_exempt = files_exempt_from_include & files_forbidden_from_include
for file in files_forbidden_and_exempt:
    post_warn(f"The file `{file}` is both forbidden from inclusion and exempt from inclusion.")
# Remove any files that are in both sets from the exempt list. This removes unnecessary warnings
# later.
files_exempt_from_include -= files_forbidden_and_exempt
del files_forbidden_and_exempt

# Get the list of .dm and .dmf files that are within `base_scanning_directory`.
def get_base_scanning_directory_file_list():
    CHECKED_FILE_EXTENSIONS = (".dm", ".dmf")
    results = set()
    directories_to_check = set([base_scanning_directory])

    while len(directories_to_check) > 0:
        directory_to_check = directories_to_check.pop()
        for entry in directory_to_check.iterdir():
            if entry.is_file() and (entry.suffix in CHECKED_FILE_EXTENSIONS):
                results.add(entry)
            elif entry.is_dir() and check_subdirectories:
                directories_to_check.add(entry)
            # We don't do anything with symlinks

    return results

files_within_scanned_directory = get_base_scanning_directory_file_list()
files_within_scanned_directory -= files_exempt_from_include
files_within_scanned_directory -= files_forbidden_from_include

# Get the list of files that are included in `includes_file`.
#
# NOTE: The variable below is a list rather than a set like the others are. This is intentional, as
# we need to keep track of what order the includes came in. However, because operations such as
# intersections will be useful to us, we still want a set - thus, after this list is populated,
# we'll spend a little bit of time making a set version as well.
pre_include_text = ""
includes_found = []
post_include_text = ""
with open(includes_file, 'r') as file:
    # Marks if we've ever seen a BEGIN_INCLUDE
    encountered_include_area = False
    # Marks if we've passed a BEGIN_INCLUDE but not an associated END_INCLUDE
    inside_include_area = False
    # The number of lines between BEGIN_INCLUDE and END_INCLUDE that we've ignored.
    ignored_line_count = 0

    for line_unstripped in file:
        line = line_unstripped.strip()
        if line == "// BEGIN_INCLUDE":
            # If we're already inside the include area, we shouldn't be seeing a BEGIN_INCLUDE
            if inside_include_area:
                post_warn(f"Unexpected nested instance of BEGIN_INCLUDE encountered.")
            encountered_include_area = True
            inside_include_area = True
            continue

        if line == "// END_INCLUDE":
            # If we're already outside the include area, we shouldn't be seeing a END_INCLUDE
            if not inside_include_area:
                post_warn(f"Unexpected END_INCLUDE encountered.")
            inside_include_area = False
            continue

        # If the line is within the include area, and appears to be an include statement, process it
        # into the file path.
        #
        # NOTE: The below code doesn't match properly if there's stuff before `#include`, or if
        # there's comment syntax in the middle of the include statement, because those aren't very
        # common. Still, if you need that functionality, the above code is what you'll want to edit.
        if inside_include_area and line.startswith("#include \""):
            # First, only take up everything to the first `//` (if it exists).
            file_path = line.partition("//")[0]
            # Next, remove the include prefix.
            file_path = file_path.removeprefix("#include")
            # Strip the whitespace and `"` from both sides, which should leave us with the file path.
            file_path = file_path.strip(' "')
            # Include paths will always be windows paths - so let's put it in a PureWindowsPath.
            # This ensures that, in the next step, the path seperators are handled properly whether
            # we're on windows or linux.
            file_path = pathlib.PureWindowsPath(file_path)
            # Prepend the DME's directory, which will convert the path seperators and give us a file
            # path relative to our repo root.
            file_path = includes_file.parent.joinpath(file_path)
            if file_path in includes_found:
                tfe_has_failed = True
                post_error(f"The file `{file_path}` is included multiple times.")
                continue
            includes_found.append(file_path)
            continue

        # If we're here, none of the above branches were taken, so we consider this line to be
        # ignored.
        if not encountered_include_area and not inside_include_area:
            pre_include_text += line_unstripped
        if encountered_include_area and not inside_include_area:
            post_include_text += line_unstripped
        pass

    # If we never entered the include area, then we never encountered a BEGIN_INCLUDE marker.
    if not encountered_include_area:
        post_error(f"Missing BEGIN_INCLUDE marker.")
        perform_exit()

    # If we are still inside the include area, then we never encountered a END_INCLUDE marker.
    if inside_include_area:
        post_error(f"Missing END_INCLUDE marker.")
        perform_exit()

# Create a set version of the includes found, because operations such as intersections are still
# very useful to us.
includes_found_set = set(includes_found)

### RESULTS PROCESSING START ###
for file_path in includes_found_set:
    # Does the includes file have any includes that match the exempt include globs? This is not
    # necessarily an error, but we give out a warning for it all the same.
    for exempt_include_glob in exempt_include_globs:
        if file_path.match(exempt_include_glob):
            post_warn(f"The file path `{file_path}` matched the unincluded file glob `{exempt_include_glob}`, but was found in the includes file.")

    # Does the includes file have any forbidden includes? This is an error if it does.
    for forbidden_include_glob in forbidden_include_globs:
        if file_path.match(forbidden_include_glob):
            tfe_has_failed = True
            post_error(f"The file path `{file_path}` is forbidden from inclusion, because it matched the forbidden include glob `{forbidden_include_glob}`.")

    # Does the includes file have any includes pointing to files that don't exist? This is an error
    # if it does.
    if not file_path.exists():
        tfe_has_failed = True
        post_error(f"The includes file includes `{file_path}`, which does not exist.")

# Is the includes file missing any includes? This is an error if it does.
missing_includes = files_within_scanned_directory - includes_found_set
# Make sure we don't check for the includes file itself.
missing_includes.discard(includes_file)
if len(missing_includes) != 0:
    tfe_has_failed = True
for file_path in missing_includes:
    post_error(f"The file path `{file_path}` is missing from the includes file.")
del missing_includes

# Is the includes file in order?
def compare_paths(a: pathlib.Path, b: pathlib.Path):
    # If the two paths are the same, return 0
    if a == b:
        # We don't need to warn here, because if two lines are the same, we've already warned about
        # duplicate includes.
        return 0

    path_segment_zip = itertools.zip_longest(
        itertools.chain(reversed(a.parents), [a]),
        itertools.chain(reversed(b.parents), [b]),
        fillvalue=None
    )

    for (a_segment, b_segment) in path_segment_zip:
        if a_segment == b_segment:
            continue

        # Is one a file, and the other a directory? The file goes first.
        # NOTE: We place the results of the .is_file() calls into a variable. This allows us to
        # avoid hammering the filesystem as much in later lines, should these two if statements not
        # be met.
        a_segment_is_file = a_segment.is_file()
        if a_segment_is_file and b_segment.is_dir():
            # Sort a before b.
            return -1
        b_segment_is_file = b_segment.is_file()
        if a_segment.is_dir() and b_segment_is_file:
            # Sort b before a.
            return 1

        ## At this point, we either have two directories, or two files, with different names.
        # If they're both files, and one of them is a DMF, the DMF comes second.
        if a_segment_is_file and b_segment_is_file:
            if a_segment.suffix == '.dmf':
                return 1
            if b_segment.suffix == '.dmf':
                return -1

        # Otherwise, compare the final path component in a case-insensitive manner -
        a_segment_name = a_segment.name.lower()
        b_segment_name = b_segment.name.lower()
        if a_segment_name < b_segment_name:
            return -1
        elif a_segment_name > b_segment_name:
            return 1

    # We shouldn't get here, but if we do, then send out an error.
    post_error(f"The paths `{a}` and `{b}` somehow did not compare properly.")
    return 0

sorted_includes = sorted(includes_found, key = functools.cmp_to_key(compare_paths))
if includes_found != sorted_includes:
    tfe_has_failed = True

    with io.StringIO() as result_string:
        result_string.write(pre_include_text)
        result_string.write("// BEGIN_INCLUDE\n")
        for include in sorted_includes:
            include_unprefixed = include.relative_to(includes_file.parent)
            string_include = pathlib.PureWindowsPath(include_unprefixed)
            print(f'#include "{string_include}"', file=result_string)
        result_string.write("// END_INCLUDE\n")
        result_string.write(post_include_text)

        with open(f"{includes_file}.sorted", "w") as includes_file_io:
            includes_file_io.write(result_string.getvalue())

    post_error("One or more includes was not sorted properly. The diff below shows the changes needed to make them sorted:")
    os.system(f"git --no-pager diff --color=always --no-index {includes_file} {includes_file}.sorted")
    os.remove(f"{includes_file}.sorted")
### RESULTS PROCESSING END ###

if tfe_has_failed:
    post_notice("Please correct the above errors.")
    perform_exit()

post_ok(f"All includes for `{includes_file}` appear to be in order!")

if on_github:
    print(f"::endgroup::")
