@echo off

cd plugin

brcc32 hpp_resource.rc

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

set DELPHILIB=c:\program files\borland\bds\4.0\lib;c:\program files\borland\delphi7\lib
set INCDIR="%DELPHILIB%;%TNTPATH%;..\inc;"
set OUTDIR=".."
set DCUDIR="tmp"
: A4 Aligned record fields  
: D Debug information          
: J  Writeable structured consts (need to compile)
: L  Local debug symbols 
: O  Optimization 
: Q  Integer overflow checking
: R  Range checking 
: Y  Symbol reference info
set COMPDIR=-$A4 -$D- -$J+ -$L- -$O+ -$Q+ -$R- -$Y-

md %OUTDIR%
md %DCUDIR%
dcc32 -B -CG -Q -W- -H- --no-config -U%INCDIR% -R%INCDIR% -I%INCDIR% -E%OUTDIR% -LE%DCUDIR% -LN%DCUDIR% -N0%DCUDIR% %COMPDIR% historypp.dpr
rd /q /s %DCUDIR%

cd ..