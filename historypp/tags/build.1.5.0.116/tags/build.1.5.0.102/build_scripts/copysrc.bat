@echo off

cd ..

md build
rd /q/s build\src 2>nul
md build\src

rem #
rem # Copy all files from curren copy to build\src
rem #

rem # Copy dirs
xcopy /S /I plugin build\src\plugin
xcopy /S /I inc build\src\inc
copy trans\hpp_translate.txt build\src
rem # Copy files
copy * build\src


rem #
rem # Find tntControls path relatively to our current dir
rem #

set TNTPATH=tntControls
set TRIES=0
:loop
if exist %TNTPATH% goto exitloop
set TNTPATH=..\%TNTPATH%
if "%TRIES%"=="000000" goto exitloop
set TRIES=0%TRIES%
goto loop
:exitloop

xcopy /S /I %TNTPATH% build\src\tntControls
