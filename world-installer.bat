@ECHO OFF
REM #######################################
REM minecraft world installer for Windows
REM 
REM @author       STS2657
REM @organization A.D. DEBUG STATION
REM @license      MIT License
REM #######################################
SETLOCAL
SET PWD=%~dp0
SET PWD=%PWD:~0,-1%
CD %PWD%
FOR %%I IN (.) DO SET CDN=%%~nxI
SET GAME_DIR=%APPDATA%\.minecraft
SET TARGET_DIR=%GAME_DIR%\saves\%CDN%

IF EXIST %TARGET_DIR% GOTO ERR_WORLD_EXIST

XCOPY %PWD% %TARGET_DIR%\ /E /W /C
IF NOT ERRORLEVEL 0 GOTO ERR_XCOPY

DEL %TARGET_DIR%\%~n0.bat

GOTO END

:ERR_WORLD_EXIST
ECHO 既に%CDN%ワールドが存在するため、コピーできません。
REM "This world exists."
GOTO END

:ERR_XCOPY
ECHO コピー中にエラーが発生したため、完全にコピーできていません。 ERRORLEVEL: %ERRORLEVEL%
GOTO END

:END
ENDLOCAL
PAUSE
EXIT
