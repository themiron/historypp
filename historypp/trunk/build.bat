@echo off

set D6LIB=c:\program files\borland\delphi6\lib
set D7LIB=c:\program files\borland\delphi7\lib
set D8LIB=c:\program files\borland\bds\2.0\lib
set D2005LIB=c:\program files\borland\bds\3.0\lib
set D2006LIB=c:\program files\borland\bds\4.0\lib

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

set GORC=utils\GoRC.exe
set TRIES=0
:loop1
if exist %GORC% goto exitloop1
set GORC=..\%GORC%
if "%TRIES%"=="00000000000" goto exitloop1
set TRIES=0%TRIES%
goto loop1
:exitloop1
if exist %GORC% goto dogorc
echo ###
echo ### Error! GoRC not fount in Utils directory
echo ### 32bit icon depth support is broken
echo ### http://www.jorgon.freeserve.co.uk/#rc
echo ###
pause
brcc32 -fohpp_resource.res hpp_resource.rc
if errorlevel 1 goto failbcc
goto exitgorc
:dogorc
%GORC% /r /nw hpp_resource.rc
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
set JCLPATH=%LIBPATH%jcl

set INCDIR="%DELPHILIB%;%TNTPATH%;%JCLPATH%;..\inc;"
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
set COMPDIR=-$A4 -$D- -$J+ -$L- -$O+ -$Q+ -$R- -$Y-

set ADDCMD=
if %DVER% GEQ 2006 set ADDCMD=--no-config

md %OUTDIR% 2>nul
md %DCUDIR% 2>nul

ren *.cfg *.cfg-build
dcc32 %ADDCMD% -B -CG -Q -W- -H- -U%INCDIR% -R%INCDIR% -I%INCDIR% -E%OUTDIR% -LE%DCUDIR% -LN%DCUDIR% -N0%DCUDIR% %COMPDIR% historypp.dpr
if errorlevel 1 ( 
  ren *.cfg-build *.cfg
  goto faildcc
)
ren *.cfg-build *.cfg

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
