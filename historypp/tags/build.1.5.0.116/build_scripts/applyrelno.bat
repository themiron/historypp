@echo off

FOR /F "TOKENS=1" %%A IN ('type relno.txt') DO SET VER=%%A
if not exist relno.txt goto nover
FOR /F "TOKENS=1,2,3,4,5 delims=._" %%A IN ("%VER%") DO (
  set MAJOR=%%A
  set MINOR=%%B
  set SUBVER=%%C
  set BUILDNO=%%D
  set TEXT=%%E)
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
set TXT1="s/{TEXT}.*{\/TEXT}/{TEXT}'%TEXT%'{\/TEXT}/g"
set TXT2="s/{\[TEXT\]}/%TEXT%/g"


set SED_NOREPL=-e %MAJ1% -e %MIN1% -e %SUB1% -e %BLD1% -e %TXT1% -e %VER1% -e %VERNO1% 
set SED_REPL=-e %MAJ2% -e %MIN2% -e %SUB2% -e %BLD2% -e %TXT2% -e %VER2% -e %VERNO2%

cd ..\plugin

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

%SED% --text %SED_NOREPL% hpp_global.pas > hpp_global.pas.sed
if errorlevel 0 move hpp_global.pas.sed hpp_global.pas

%SED% --text %SED_NOREPL% %SED_REPL% hpp_res_ver.rc.txt > hpp_res_ver.rc.sed
if errorlevel 0 move hpp_res_ver.rc.sed hpp_res_ver.rc

%SED% --text %SED_NOREPL% %SED_REPL% historypp.dpr > historypp.dpr.sed
if errorlevel 0 move historypp.dpr.sed historypp.dpr

cd ..\build_scripts

goto end

:nover
echo Error! No relno.txt
goto end

:end