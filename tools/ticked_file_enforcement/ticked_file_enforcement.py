import fnmatch
import functools
import glob
import json
import os
import sys

# simple way to check if we're running on github actions, or on a local machine
on_github = os.getenv("GITHUB_ACTIONS") == "true"

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def blue(text):
    return "\033[34m" + str(text) + "\033[0m"

### BEGIN SCHEMA ###
schema = json.load(sys.stdin)

# (String: File path) The file that we want to take includes from
includes_file = schema["includes_file"]

# (String: Directory path) The base directory from which to collect file paths that we want to
# ensure are included in `includes_file`. Any files in `includes_file` that do not come from this
# directory are ignored.
base_scanning_directory = schema["base_scanning_directory"]

# (Boolean) If we should consider the files from subdirectories of `base_scanning_directory`, when
# generating a list of files that should be within `includes_file`.
check_subdirectories = schema["check_subdirectories"]

# (Array of strings: File pathname patterns) File paths within `base_scanning_directory` that are
# intentionally not included in `includes_file`. It is NOT an error for a file matching one of these
# patterns to be included in `includes_file`, but we will warn regardless.
unincluded_files = schema["unincluded_files"]

# (Array of strings: File pathname patterns) File paths that are not allowed to be included in
# `includes_file`. It is an error for a file matching one of these patterns to be included in
# `includes_file`.
forbidden_includes = schema["forbidden_includes"]
### END SCHEMA ###

def post_error(string):
    print(red(f"Ticked File Enforcement [{file_reference}]: " + string))
    if on_github:
        print(f"::error file={file_reference},line=1,title=Ticked File Enforcement::{string}")

for excluded_file in excluded_files:
    full_file_path = scannable_directory + excluded_file
    if not os.path.isfile(full_file_path):
        post_error(f"Excluded file {full_file_path} does not exist, please remove it!")
        sys.exit(1)

file_extensions = ("dm", "dmf")

reading = False
lines = []
total = 0

with open(file_reference, 'r') as file:
    for line in file:
        total += 1
        line = line.strip()

        if line == "// BEGIN_INCLUDE":
            reading = True
            continue
        elif line == "// END_INCLUDE":
            break
        elif not reading:
            continue

        lines.append(line)

offset = total - len(lines)
print(blue(f"Ticked File Enforcement: {offset} lines were ignored in output for [{file_reference}]."))
fail_no_include = False

scannable_files = []
for file_extension in file_extensions:
    compiled_directory = f"{scannable_directory}/**/*.{file_extension}"
    scannable_files += glob.glob(compiled_directory, recursive=True)

if len(scannable_files) == 0:
    post_error(f"No files were found in {scannable_directory}. Ticked File Enforcement has failed!")
    sys.exit(1)

for code_file in scannable_files:
    dm_path = ""

    if subdirectories is True:
        dm_path = code_file.replace('/', '\\')
    else:
        dm_path = os.path.basename(code_file)

    included = f"#include \"{dm_path}\"" in lines

    forbid_include = False
    for forbidable in FORBIDDEN_INCLUDES:
        if not fnmatch.fnmatch(code_file, forbidable):
            continue

        forbid_include = True

        if included:
            post_error(f"{dm_path} should NOT be included.")
            fail_no_include = True

    if forbid_include:
        continue

    if not included:
        if(dm_path == file_reference_basename):
            continue

        if(dm_path in excluded_files):
            continue

        post_error(f"Missing include for {dm_path}.")
        fail_no_include = True

if fail_no_include:
    sys.exit(1)

def compare_lines(a, b):
    # Remove initial include as well as the final quotation mark
    a = a[len("#include \""):-1].lower()
    b = b[len("#include \""):-1].lower()

    split_by_period = a.split('.')
    a_suffix = ""
    if len(split_by_period) >= 2:
        a_suffix = split_by_period[len(split_by_period) - 1]
    split_by_period = b.split('.')
    b_suffix = ""
    if len(split_by_period) >= 2:
        b_suffix = split_by_period[len(split_by_period) - 1]

    a_segments = a.split('\\')
    b_segments = b.split('\\')

    for (a_segment, b_segment) in zip(a_segments, b_segments):
        a_is_file = a_segment.endswith(file_extensions)
        b_is_file = b_segment.endswith(file_extensions)

        # code\something.dm will ALWAYS come before code\directory\something.dm
        if a_is_file and not b_is_file:
            return -1

        if b_is_file and not a_is_file:
            return 1

        # interface\something.dm will ALWAYS come after code\something.dm
        if a_segment != b_segment:
            # if we're at the end of a compare, then this is about the file name
            # files with longer suffixes come after ones with shorter ones
            if a_suffix != b_suffix:
                return (a_suffix > b_suffix) - (a_suffix < b_suffix)
            return (a_segment > b_segment) - (a_segment < b_segment)

    print(f"Two lines were exactly the same ({a} vs. {b})")
    sys.exit(1)

sorted_lines = sorted(lines, key = functools.cmp_to_key(compare_lines))
for (index, line) in enumerate(lines):
    if sorted_lines[index] != line:
        post_error(f"The include at line {index + offset} is out of order ({line}, expected {sorted_lines[index]})")
        sys.exit(1)

print(green(f"Ticked File Enforcement: [{file_reference}] All includes (for {len(scannable_files)} scanned files) are in order!"))
