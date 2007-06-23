@echo off

if /i "%1"=="r+" goto ok1
if /i "%1"=="r-" goto ok1
goto usage
:ok1
if ""%2""=="""" goto usage
if not exist %2 goto noexist
set DEST=%3
if ""%DEST%""=="""" set DEST=%2

FOR /F "TOKENS=1" %%A IN ('type relno.txt') DO SET VER=%%A
if not exist relno.txt goto nover

FOR /F "TOKENS=1* delims=_" %%A IN ("%VER%") DO (
  set FIRST=%%A
  set TEXT=%%B
)

FOR /F "TOKENS=1,2,3,4,5 delims=._" %%A IN ("%FIRST%") DO (
  set MAJOR=%%A
  set MINOR=%%B
  set SUBVER=%%C
  set BUILDNO=%%D
)

set VERNO=%MAJOR%.%MINOR%.%SUBVER%.%BUILDNO%
if not "%TEXT%"=="" set VER=%VERNO% %TEXT%

set VERNO1="s/{VERNO}.*{\/VERNO}/{VERNO}%VERNO%{\/VERNO}/g"
set VERNO2="s/{\[VERNO\]}/%VERNO%/g"
set VER1="s/{VER}.*{\/VER}/{VER}%VER%{\/VER}/g"
set VER2="s/{\[VER\]}/%VER%/g"
set MAJ1="s/{MAJOR_VER}.*{\/MAJOR_VER}/{MAJOR_VER}%MAJOR%{\/MAJOR_VER}/g"
set MAJ2="s/{\[MAJOR_VER\]}/%MAJOR%/g"
set MIN1="s/{MINOR_VER}.*{\/MINOR_VER}/{MINOR_VER}%MINOR%{\/MINOR_VER}/g"
set MIN2="s/{\[MINOR_VER\]}/%MINOR%/g"
set SUB1="s/{SUB_VER}.*{\/SUB_VER}/{SUB_VER}%SUBVER%{\/SUB_VER}/g"
set SUB2="s/{\[SUB_VER\]}/%SUBVER%/g"
set BLD1="s/{BUILD}.*{\/BUILD}/{BUILD}%BUILDNO%{\/BUILD}/g"
set BLD2="s/{\[BUILD\]}/%BUILDNO%/g"

set SED_NOREPL=-e %MAJ1% -e %MIN1% -e %SUB1% -e %BLD1% -e %VER1% -e %VERNO1% 
set SED_REPL=-e %MAJ2% -e %MIN2% -e %SUB2% -e %BLD2% -e %VER2% -e %VERNO2%

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

set CLINE=%SED_NOREPL%
if /i "%1"=="r+" set CLINE=%CLINE% %SED_REPL% 

%SED% %CLINE% %2 > sed_tmp
if errorlevel 0 (
  move sed_tmp %DEST%
  goto end )

goto sederror

goto end

:sederror
echo SED returned error
echo Failed transforming %2
echo File is unchanged, results are in sed_tmp file
exit

:noexist
echo Error! File %2 not exists
exit

:usage
echo:
echo Use change_vars.bat [OPTIONS] infile [outfile]
echo:
echo Options:
echo   r+ -- replace {[]} and change {}xxx{/} style vars
echo   r- -- change only {}xxx{/} style vars
echo:
echo Example: 
echo  * replace_vars r- somefile
echo    Replaces vars {}xxx{/} style and saves changes in somefile
echo:
echo  * replace_vars r+ somefile outfile
echo    Replaces all kind vars and writes to outfile 
echo:
exit

:nover
echo Error! No relno.txt Run setrelno.bat
exit

:end