@echo off

cd plugin

brcc32 > nul 2>&1
if errorlevel 2 goto nobcc
dcc32 > nul 2>&1
if errorlevel 1 goto nodcc


brcc32 -fohpp_resource.res hpp_resource.rc
if errorlevel 1 goto failbcc
brcc32 -fohpp_res_ver.res hpp_res_ver.rc
if errorlevel 1 goto failbcc

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

set DELPHILIB=c:\program files\borland\bds\4.0\lib;c:\program files\borland\delphi7\lib;c:\program files\borland\bds\2.0\lib;c:\program files\borland\bds\3.0\lib
set INCDIR="%DELPHILIB%;%TNTPATH%;..\inc;"
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

md %OUTDIR% 2>nul
md %DCUDIR% 2>nul
dcc32 -B -CG -Q -W- -H- --no-config -U%INCDIR% -R%INCDIR% -I%INCDIR% -E%OUTDIR% -LE%DCUDIR% -LN%DCUDIR% -N0%DCUDIR% %COMPDIR% historypp.dpr
if errorlevel 1 goto faildcc
rd /q /s %DCUDIR%

goto end

:nodcc
set ERRSTR=Delphi Compiler [dcc32.exe] NOT FOUND!
goto error

:nobcc
set ERRSTR=Borland Resource Compiler [brcc32.exe] NOT FOUND!
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
