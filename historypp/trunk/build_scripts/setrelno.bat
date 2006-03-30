@echo off

if not exist relno.txt echo: > relno.txt
FOR /F "TOKENS=1" %%A IN ('type relno.txt') DO SET CURVER=%%A

echo:
echo Enter release number
echo:
echo Format: 
echo    MAJOR.MINOR.SUBVER.BUILDNO[_subname]
echo:
echo Examples:
echo    Release 1.5.1:          1.5.1.0
echo    Version 1.5, build #12: 1.5.0.12
echo    Alpha version:          1.5.0.0_alpha
echo:
echo Current release: %CURVER%
echo:
SET /P VA=[Enter release] 
IF NOT "%VA%"=="" (
 echo %VA% > relno.txt
 set CURVER=%VA% )

echo:
echo Release set to %CURVER%
echo: