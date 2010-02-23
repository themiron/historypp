@echo off

set UPXLONGPATH="c:\program files\upx\upx.exe"
set ZIPLONGPATH="c:\program files\7-zip\7z.exe"
set ALPHA=

rem #
rem # Find UPX
rem #
set UPXPATH="upx"
%UPXPATH% -V > nul 2>&1
if not errorlevel 1 goto haveupx
set UPXPATH=%UPXLONGPATH%
%UPXPATH% -V > nul 2>&1
if not errorlevel 1 goto haveupx
goto missupx
:haveupx

rem #
rem # Find 7-zip
rem #
set ZPATH="7z.exe"
%ZPATH% > nul 2>&1
if not errorlevel 1 goto havezip
set ZPATH=%ZIPLONGPATH%
%ZPATH% > nul 2>&1
if not errorlevel 1 goto havezip
goto misszip
:havezip

:start
FOR /F "TOKENS=1" %%A IN ('type relno.txt') DO SET VER_=%%A
if not exist relno.txt set VER_=nover

echo:
echo --------- Make History++ Distribution ---------
echo:
echo This script will make binary and source distributives
echo of the current version. To change current version run
echo setrelno.bat
echo:
echo Upx.exe path: %UPXPATH%
echo 7-z.exe path:  %ZPATH%
echo:
echo Current release: %VER_%
echo:
echo Following files will be generated:
echo    build\historypp-%VER_%-bin.zip
echo    build\historypp-%VER_%-src.zip
echo:
echo Y - proceed, N - quit, R - set release no
:askproceed
set ANS=
set /p ANS=Proceed? [Y,N,R] 
if /I "%ANS%"=="Y" goto proceed
if /I "%ANS%"=="N" exit
if /I "%ANS%"=="R" (
  call setrelno.bat
  goto start )
if "%ANS%"=="" exit
echo Unknown command: "%ANS%"
goto askproceed
:proceed

rd /q/s ..\build 2>nul

echo:
echo Preparing translation...
echo:
call make_translation.bat

echo:
echo Copying sources...
echo:
call copysrc.bat
rem # we are now in cd ..

cd build\src
call build.bat
if errorlevel 1 goto builderr

%UPXPATH% --force --best --all-methods --crp-ms=999999 --no-backup --overlay=copy --compress-exports=0 --compress-resources=0 --strip-relocs=0 historypp.dll
if errorlevel 1 goto upxerr

md ..\bin
md ..\bin\icons
md ..\bin\docs
move historypp.dll ..\bin
move historypp_icons.dll ..\bin\icons
copy hpp_translate.txt ..\bin\docs
copy ..\..\hpp_changelog.txt ..\bin\docs
copy ..\..\plugin\m_historypp.inc ..\bin\docs

cd ..\bin

%ZPATH% a -y -tzip -mx ..\historypp-%VER_%-bin.zip *
if errorlevel 1 goto ziperr

cd ..\src
rem # a bit of saftiness here
if errorlevel 1 (
  echo Error! Can not change dirs
  exit )

del /S /Q /F *.bak
del /S /Q /F *.ddp
del /S /Q /F *.dcu
del /S /Q /F *.bpl
del /S /Q /F *.cfg
del /S /Q /F *.ddp
del /S /Q /F *.dsk
del /S /Q /F *.~*
del /S /Q /F *.bk?
del /S /Q /F *.bdsproj
del /S /Q /F *.bdsproj.local
del /S /Q /F *.dof
del /S /Q /F *.drc
del /S /Q /F *.identcache
del /S /Q /F *.map
del /S /Q /F *.todo
del /S /Q /F *.rsm

%ZPATH% a -y -tzip -r -mx ..\historypp-%VER_%-src.zip *
if errorlevel 1 goto ziperr

cd ..
rd /q/s src
rd /q/s bin

goto end

:missupx
set ERR1=Can not find UPX in path and in default location
set ERR2=See source to modify path
goto error

:misszip
set ERR1=Can not find 7-ZIP in path and in default location
set ERR2=See source to modify path
goto error

:upxerr
set ERR1=Error occured while packing with UPX
goto error

:ziperr
set ERR1=Error occured while making archive with 7-zip
goto error

:builderr
set ERR1=Build failed
goto error

:error
if "%ERR1%"=="" set ERR1="Unknown error"
if "%ERR2%"=="" set ERR2="See output for error details"

echo ###
echo ### Error! Can not make distribution!
echo ###
echo ### %ERR1%
echo ### %ERR2%
echo ###
pause
exit

:end
pause