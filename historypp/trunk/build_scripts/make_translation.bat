@echo off

copy ..\plugin\*.trans.txt hpp_t.txt

rem #
rem # Find Utils path relatively to our current dir
rem #

set UTILSPATH=utils
set TRIES=0
:loop
if exist %UTILSPATH% goto exitloop
set UTILSPATH=..\%UTILSPATH%
if "%TRIES%"=="000000" goto exitloop
set TRIES=0%TRIES%
goto loop
:exitloop

set SED=%UTILSPATH%\sed.exe

%SED% --text -f rem_dupes.sed hpp_t.txt > hpp_trans.txt
del hpp_t.txt