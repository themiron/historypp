@echo off

rem #
rem # Build debug build with Eureka Log information built-in
rem # 
rem # How to use in History++ svn:
rem #  * Download and install Eureak Log trial from http://www.eurekalog.com/
rem #  * When you turn Eureka Log on, it puts ExceptionLog unit first in
rem #    the project's uses clause, but you need to put it in IFDEFs
rem #    Make sure historypp.dpr uses STARTS with:
rem #    {$IFDEF EUREKALOG}
rem #    ExceptionLog,
rem #    {$ENDIF}
rem #  * Remove "Eureka Log VER" package from Installed Packages
rem #  * Now you can open historypp project in dephi IDE without trial package 
rem #    (and trial nag screen), to build historypp with eureka 
rem #    log support, run this script
rem #  
rem #  Some notes:
rem #    To change eureka log options, you can either edit historypp.eof or
rem #    do it within IDE, but you'll need eureka's package installed.
rem #    You can add package again to the list of Installed Packages and
rem #    change options thorugh Project -> Eureka Log Options
rem #    Make sure to press "Load options file", load historypp.eof
rem #    After changing, save options to historypp.eof file. 
rem #    You can disable package again after that.
rem #    Make sure historypp.dpr uses clause is as peviously written 
rem #    (ExceptionLog unit between ifdef's)
rem #

set D6LIB=%ProgramFiles%\borland\delphi6\lib
set D7LIB=%ProgramFiles%\borland\delphi7\lib
set D8LIB=%ProgramFiles%\borland\bds\2.0\lib
set D2005LIB=%ProgramFiles%\borland\bds\3.0\lib
set D2006LIB=%ProgramFiles%\borland\bds\4.0\lib

brcc32 > nul 2>&1
if errorlevel 2 goto nobcc
dcc32 > nul 2>&1
if errorlevel 1 goto nodcc

cd plugin

rem #
rem # Get delphi compiler version
rem #
rem # DVER contains Delphi complier version
rem # DVER == 2006 - Delphi 2006    (borland\bds\4.0)
rem # DVER == 2005 - Delphi 2005    (borland\bds\3.0)
rem # DVER == 8    - Delphi 8       (borland\bds\2.0)
rem # DVER == 7    - Delphi 7       (borland\delphi7)
rem # DVER == 6    - Delphi 6       (borland\delphi6)
rem # DVER == 5    - Delphi 5       (borland\delphi5)

FOR /F "TOKENS=1,2,3,4,5,6,7,8" %%A IN ('dcc32') DO (
  if /i %%A==Borland (
    if /i %%B==version set DVER=%%C
    if /i %%C==version set DVER=%%D
    if /i %%D==version set DVER=%%E
    if /i %%E==version set DVER=%%F
    if /i %%F==version set DVER=%%G
    if /i %%G==version set DVER=%%H
    if /i %%H==version set DVER=%%I
  )
)
FOR /F "TOKENS=1,2 delims=." %%A IN ("%DVER%") DO set DVER=%%A
if %DVER%==18 set DVER=2006
if %DVER%==17 set DVER=2005
if %DVER%==16 set DVER=8
if %DVER%==15 set DVER=7
if %DVER%==14 set DVER=6
if %DVER%==13 set DVER=5

rem #
rem # Find Delphi Lib dir
rem #
set DELPHILIB=
if %DVER%==6 set DELPHILIB=%D6LIB%
if %DVER%==7 set DELPHILIB=%D7LIB%
if %DVER%==8 set DELPHILIB=%D8LIB%
if %DVER%==2005 set DELPHILIB=%D2005LIB%
if %DVER%==2006 set DELPHILIB=%D2006LIB%
if not exist "%DELPHILIB%" set DELPHILIB=
if "%DELPHILIB%"=="" goto nolib

echo:
echo * Delphi version detected: Delphi %DVER% 
echo * Lib files found at:
echo * %DELPHILIB%
echo * Building project...
echo:

brcc32 -fohpp_res_ver.res hpp_res_ver.rc
if errorlevel 1 goto failbcc
brcc32 -fohpp_opt_dialog.res hpp_opt_dialog.rc
if errorlevel 1 goto failbcc

rem #
rem # Find utils path relatively to our current dir
rem #

set UTILS=utils
set TRIES=0
:loop1
if exist %UTILS% goto exitloop1
set UTILS=..\%UTILS%
if "%TRIES%"=="00000000000" goto exitloop1
set TRIES=0%TRIES%
goto loop1
:exitloop1

if exist %UTILS%\GoRC.exe goto dogorc
echo ###
echo ### Warning! GoRC not fount in Utils directory
echo ### Using Borland Resource Compiler instead
echo ### Support for icons with 32-bit color depth would be broken
echo ### 
echo ### Download gorc.exe from http://www.jorgon.freeserve.co.uk/#rc
echo ###
pause
brcc32 -fohpp_resource.res hpp_resource.rc
if errorlevel 1 goto failbcc
brcc32 -fohistorypp_icons.res historypp_icons.rc
goto exitgorc
:dogorc
%UTILS%\GoRC /r /nw hpp_resource.rc
%UTILS%\GoRC /r/o /nw historypp_icons.rc
:exitgorc

rem #
rem # Find tntControls path relatively to our current dir
rem #

set TNTPATH=tntControls
set LIBPATH=
set TRIES=0
:loop
if exist %TNTPATH% goto exitloop
set LIBPATH=..\%LIBPATH%
set TNTPATH=..\%TNTPATH%
if "%TRIES%"=="000000" goto exitloop
set TRIES=0%TRIES%
goto loop
:exitloop
set TNTPATH=%TNTPATH%;%TNTPATH%\Source
set TRDPATH=%LIBPATH%3rdparty

set INCDIR="%DELPHILIB%;%TNTPATH%;%TRDPATH%;..\inc;"
set OUTDIR=".."
set DCUDIR="tmp"
: A4 Aligned record fields  
: D Debug information          
: J+  Writeable structured consts (NEED ON)
: L  Local debug symbols 
: O  Optimization 
: Q  Integer overflow checking
: R- Range checking (NEED OFF?)
: Y  Symbol reference info
set COMPDIR=-$A4 -$D+ -$J+ -$L+ -$O+ -$Q+ -$R- -$Y+ -$W+ -$C+
if not "%ALPHA%"=="" set COMPDIR=%COMPDIR% -DALPHA
if not "%NO_EG%"=="" set COMPDIR=%COMPDIR% -DNO_EXTERNALGRID

set EUDIR=--el_config"historypp.eof" -DEUREKALOG;EUREKALOG_VER5

set ADDCMD=
if %DVER% GEQ 2006 set ADDCMD=--no-config

md %OUTDIR% 2>nul
md %DCUDIR% 2>nul

ren *.cfg *.cfg-build
copy /y alpha.inc alpha-build.inc
if not "%ALPHA%"=="" echo %ALPHA% > alpha.inc
ecc32 %ADDCMD% %EUDIR%  -B -CG -Q -W- -H- -U%INCDIR% -R%INCDIR% -I%INCDIR% -E%OUTDIR% -LE%DCUDIR% -LN%DCUDIR% -N0%DCUDIR% %COMPDIR% historypp.dpr
if errorlevel 1 ( 
  ren *.cfg-build *.cfg
  copy /y alpha-build.inc alpha.inc
  del alpha-build.inc
  goto faildcc
)
ren *.cfg-build *.cfg
copy /y alpha-build.inc alpha.inc
del alpha-build.inc

del %OUTDIR%\historypp.map
del %OUTDIR%\historypp.rsm

if exist %UTILS%\GoLink.exe goto dogolink
echo ###
echo ### Warning! GoLink not fount in Utils directory
echo ### Using Delphi Compiler instead
echo ### The resulting historypp_icons.dll would be a bit bigger
echo ### 
echo ### Download golink.exe from http://www.jorgon.freeserve.co.uk/#linker
echo ###
echo:
ren *.cfg *.cfg-build
dcc32 %ADDCMD% -B -CG -Q -W- -H- -U%INCDIR% -R%INCDIR% -I%INCDIR% -E%OUTDIR% -LE%DCUDIR% -LN%DCUDIR% -N0%DCUDIR% %COMPDIR% historypp_icons.dpr
if errorlevel 1 ( 
  ren *.cfg-build *.cfg
  goto faildcc
)
ren *.cfg-build *.cfg
goto exitgolink

:dogolink
%UTILS%\GoLink historypp_icons.obj /nw /base 10000000 /fo ..\historypp_icons.dll
:exitgolink

rd /q /s %DCUDIR%

goto end

:nodcc
set ERRSTR=Delphi Compiler [dcc32.exe] NOT FOUND!
goto error

:nobcc
set ERRSTR=Borland Resource Compiler [brcc32.exe] NOT FOUND!
goto error

:nolib
set ERRSTR=Can not find Delphi Lib directory. See source file.
goto error

:failbcc
set ERRSTR=Borland resource compiler failed compiling the resources!
goto error

:faildcc
set ERRSTR=Delphi Compiler failed building the plugin!
goto error

:error
echo ###
echo ### Error! Can not build!
echo ### %ERRSTR%
echo ###
exit

:end
cd ..
