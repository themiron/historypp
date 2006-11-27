@echo off

rem #
rem # To find PHP bin, set your path to include php directory
rem # or set PHP environment variable to PHP binary, like
rem # SET PHP=C:\PHP\php.exe
rem #

set PHPBIN=%PHP%
%PHPBIN% -h > nul 2>&1
if not errorlevel 2 goto gotphp
set PHPBIN=php
%PHPBIN% -h > nul 2>&1
if not errorlevel 2 goto gotphp
set PHPBIN=\php\php
%PHPBIN% -h > nul 2>&1
if not errorlevel 2 goto gotphp
goto nophp
:gotphp

set TRANSNAME=hpp_translate.txt

md ..\trans > nul 2>&1
del /Q ..\trans\*.* > nul 2>&1


set TRANS=hpp_t.txt

call change_vars.bat r+ trans_header.txt ..\trans\hpp_t.txt

echo Running PHP to grab all translations...

rem FOR %%A IN (..\plugin\*.dfm) DO (
FOR %%A IN (..\plugin\*.pas) DO (
  %PHPBIN% -q -d html_errors=false trans.php %%A
)
FOR %%A IN (..\plugin\*.dpr) DO (
  %PHPBIN% -q -d html_errors=false trans.php %%A
)

cd ..\plugin

move *.trans.txt ..\trans\ > nul 2>&1
move *.trans-err.txt ..\trans\ > nul 2>&1
move *.trans-detailed.txt ..\trans\ > nul 2>&1

rem # cd ..\trans

cd ..\build_scripts

echo Running PHP to put them together...

%PHPBIN% -q -d html_errors=false implode.php ..\trans\*.trans.txt >> ..\trans\%TRANS%

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

echo Transforming them with SED...

set SED=%UTILSPATH%\sed.exe

%SED% --text -f rem_dupes.sed ..\trans\hpp_t.txt > ..\trans\hpp_tmp.txt
move ..\trans\hpp_tmp.txt ..\trans\hpp_t.txt
%SED% --text -f rem_doubles.sed ..\trans\hpp_t.txt > ..\trans\hpp_tmp.txt
move ..\trans\hpp_tmp.txt ..\trans\hpp_t.txt

rem if you don't want to enclose strings in [], then comment it
%SED% --text -f enclose.sed ..\trans\hpp_t.txt > ..\trans\hpp_tmp.txt
move ..\trans\hpp_tmp.txt ..\trans\hpp_t.txt

move ..\trans\hpp_t.txt ..\trans\%TRANSNAME%

echo Done!

if exist ..\trans\*.trans-err.txt goto trans_have_errors

goto end

:nophp
echo:
echo ##
echo ## Error! PHP binary not found!
echo ##
echo:
goto end

:trans_have_errors
echo:
echo ##
echo ## Warning! Translation tool found errors!
echo ##
echo:
echo List of files with errors:
dir /B ..\trans\*.trans-err.txt
echo:
pause
goto end

:end