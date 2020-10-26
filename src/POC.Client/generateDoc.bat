@echo off
setlocal
SET PATH=%PATH%;
doxygen.exe doxyfile
for %%i in (Doc\*.*) do if not "%%i"=="Doc\doc.chm" del /q "%%i"