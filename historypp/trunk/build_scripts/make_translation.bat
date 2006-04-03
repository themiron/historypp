@echo off

rem copy ..\plugin\*.trans.txt hpp_t.txt

set TRANS=..\build_scripts\hpp_t.txt

call change_vars.bat r+ trans_header.txt hpp_t.txt

cd ..\plugin

FOR %%A IN (*.trans.txt) DO (
echo:>>%TRANS%
echo:>>%TRANS%
rem echo ;;>> %TRANS%
echo ;; %%A file >> %TRANS%
echo:>>%TRANS%
rem echo ;;>> %TRANS%
type %%A >> %TRANS%
)
cd ..\build_scripts

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

%SED% --text -f rem_dupes.sed hpp_t.txt > hpp_tmp.txt
move hpp_tmp.txt hpp_t.txt
%SED% --text -f rem_doubles.sed hpp_t.txt > hpp_tmp.txt
move hpp_tmp.txt hpp_t.txt

rem if you don't want to enclose strings in [], then comment it
%SED% --text -f enclose.sed hpp_t.txt > hpp_tmp.txt
move hpp_tmp.txt hpp_t.txt

move hpp_t.txt hpp_trans.txt