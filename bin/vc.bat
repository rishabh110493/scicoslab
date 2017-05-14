@echo off
rem This file is used by findmsvccompiler
rem to run vcvarsall.bat and obtain the env variables
cd "%1"
call "vcvarsall.bat"
set
