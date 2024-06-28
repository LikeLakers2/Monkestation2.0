@echo off
echo ---- NOTICE TESTS ----

echo.
echo ---- WARNING TESTS ----

echo.
echo ---- ERROR TESTS ----
type tools\ticked_file_enforcement\tests\errors\nonexistent_exclude.json | tools\bootstrap\python tools\ticked_file_enforcement\ticked_file_enforcement_monke.py
