@echo off
echo ---- NOTICE TESTS ----
type tools\ticked_file_enforcement\tests\includes_file_should_have_includes.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py

echo.
echo ---- WARNING TESTS ----
type tools\ticked_file_enforcement\tests\begin_include_should_not_be_nested.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\unincluded_glob_should_match_a_file.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\unincluded_globs_should_not_match_included_file.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\warn_if_end_include_without_begin_include.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py

echo.
echo ---- ERROR TESTS ----
type tools\ticked_file_enforcement\tests\base_scanning_directory_must_be_valid.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\includes_file_must_have_begin_include.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
type tools\ticked_file_enforcement\tests\includes_file_must_have_end_include.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement.py
echo.
