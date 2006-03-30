@echo off

set UPXPATH="c:\program files\upx\upx.exe"
set ZPATH="c:\program files\7-zip\7z.exe"

:start
FOR /F "TOKENS=1" %%A IN ('type relno.txt') DO SET VER=%%A
if not exist relno.txt set VER=nover

echo --------- Make History++ Distributive ---------
echo:
echo This script will make binary and source distributives
echo of the current version. To change current version run
echo setrelno.bat
echo:
echo Upx.exe path: %UPXPATH%
echo 7-z.exe path:  %ZPATH%
echo:
echo Current release: %VER%
echo:
echo Following files will be generated:
echo    build\historypp-%VER%-bin.zip
echo    build\historypp-%VER%-src.zip
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

rd /q/s ..\build

call copysrc.bat
rem # we are now in cd ..

cd build\src
call build.bat

%UPXPATH% --force --best --crp-ms=999999 --nrv2d historypp.dll

move historypp.dll ..

cd ..

%ZPATH% a -tzip -mx historypp-%VER%-bin.zip historypp.dll

cd src

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

%ZPATH% a -tzip -r -mx ..\historypp-%VER%-src.zip *

cd ..
rd /q/s src
del historypp.dll

pause