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

def yellow(text):
    return "\033[33m" + str(text) + "\033[0m"

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
unincluded_file_globs = schema["unincluded_file_globs"]

# (Array of strings: File pathname patterns) File paths that are not allowed to be included in
# `includes_file`. It is an error for a file matching one of these patterns to be included in
# `includes_file`.
forbidden_include_globs = schema["forbidden_include_globs"]
### END SCHEMA ###

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

def find_in_includes(file_path):
    if file_path in includes_found:
        return True
    else:
        return False


### BEGIN PROCESSING ###
if on_github:
    print(f"::group::Ticked File Enforcement [{includes_file}]")
print(f"Processing `{includes_file}`...")

# Ticked files should always be in the same directory, or a subdirectory, as the include file.
includes_file_directory = os.path.dirname(includes_file) + "/"
if not base_scanning_directory.startswith(includes_file_directory):
    post_error(f"The base scanning directory is not in the same directory or a subdirectory as the includes file.")
    sys.exit(1)

# Process the unincluded file globs to create the actual file globs we want.
compiled_unincluded_file_globs = []
for unincluded_file_glob in unincluded_file_globs:
    full_file_glob = base_scanning_directory + unincluded_file_glob
    file_list = glob.glob(full_file_glob, recursive=True)
    if len(file_list) == 0:
        post_warn(f"The unincluded file glob `{full_file_glob}` does not match any files.")
        # Since we know this doesn't match any files, let's skip adding this to the list of
        # processed globs.
        continue
    compiled_unincluded_file_globs.append(full_file_glob)

def matches_unincluded_file_glob(file_path):
    for compiled_unincluded_file_glob in compiled_unincluded_file_globs:
        if fnmatch.fnmatch(file_path, compiled_unincluded_file_glob):
            return True
    return False

# Get the list of files that are included in `includes_file`
includes_found = []
with open(includes_file, 'r') as file:
    # Marks if we've ever seen a BEGIN_INCLUDE
    encountered_include_area = False
    # Marks if we've passed a BEGIN_INCLUDE but not an associated END_INCLUDE
    inside_include_area = False
    # The number of lines between BEGIN_INCLUDE and END_INCLUDE that we've ignored.
    ignored_line_count = 0

    for line in file:
        line = line.strip()
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

        if inside_include_area and line.startswith("#include \""):
            # Let's get the file path. First, only take up everything to the first `//` (if it exists)
            file_path = line.partition("//")[0]
            # Next, remove the include prefix.
            file_path = file_path.removeprefix("#include")
            # Strip any whitepsace from both sides.
            file_path = file_path.strip()
            # Our file path is everything between the beginning and end quotes.
            file_path = file_path[1:-1]
            # Finally, prepend the DME's directory.
            file_path = includes_file_directory + file_path
            # If the file path matches one of the unincluded file globs, spit out a warning.
            if matches_unincluded_file_glob(file_path):
                post_warn(f"The file path `{file_path}` matched a unincluded file glob, but was found in the includes file.")
            includes_found.append(file_path)
            continue

        # If we're here, none of the above branches were taken, so we consider this line to be
        # ignored.
        ignored_line_count += 1

    # If we never entered the include area, then we never encountered a BEGIN_INCLUDE marker.
    if not encountered_include_area:
        post_error(f"Missing BEGIN_INCLUDE marker.")
        sys.exit(1)

    # If we are still inside the include area, then we never encountered a END_INCLUDE marker.
    if inside_include_area:
        post_error(f"Missing END_INCLUDE marker.")
        sys.exit(1)

    if ignored_line_count != 0:
        post_notice(f"{ignored_line_count} lines were ignored while processing the includes file.")

if len(includes_found) == 0:
    post_notice(f"No includes found within the includes file. Exiting.")
    sys.exit()


if on_github:
    print(f"::endgroup::")

file_extensions = ("dm", "dmf")
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
