@echo off
echo ---- NOTICE TESTS ----
echo No tests.
echo.

echo ---- WARNING TESTS ----
type tools\ticked_file_enforcement\tests\begin_include_should_not_be_nested.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\end_include_should_not_be_outside_include_area.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\includes_file_should_not_have_exempt_includes.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\schema\exempt_include_glob_should_match_a_file.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\schema\exempt_include_globs_should_not_match_files_multiple_times.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\schema\files_should_not_be_both_exempt_and_forbidden.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\schema\forbidden_include_glob_should_match_a_file.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.

echo ---- ERROR TESTS ----
type tools\ticked_file_enforcement\tests\includes_file_must_not_have_forbidden_includes.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\includes_file_must_not_include_a_file_multiple_times.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.

echo ---- FATAL ERROR TESTS ----
type tools\ticked_file_enforcement\tests\includes_file_must_have_begin_include.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\includes_file_must_have_end_include.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\schema\base_scanning_directory_must_be_within_includes_file_directory.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\schema\base_scanning_directory_must_point_to_existing_directory.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\schema\includes_file_must_point_to_existing_file.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
