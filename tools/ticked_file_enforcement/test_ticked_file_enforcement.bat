@echo off
echo ---- NOTICE TESTS ----
type tools\ticked_file_enforcement\tests\notices\no_includes.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement_monke.py

echo.
echo ---- WARNING TESTS ----
type tools\ticked_file_enforcement\tests\warnings\end_include_without_begin_include.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement_monke.py
type tools\ticked_file_enforcement\tests\warnings\nested_begin_include.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement_monke.py

echo.
echo ---- ERROR TESTS ----
type tools\ticked_file_enforcement\tests\errors\missing_begin_include.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement_monke.py
type tools\ticked_file_enforcement\tests\errors\missing_end_include.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement_monke.py
type tools\ticked_file_enforcement\tests\errors\nonexistent_exclude.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement_monke.py
