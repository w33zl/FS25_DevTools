:: ############################################################################
:: # FS Dev Tools: Builder v1.0 - Copyright w33zl / WZL Modding               #
:: ############################################################################

@echo off
echo.
echo ***************************************************************
echo * FS DevTools: Build Command - Created by w33zl (WZL Modding) *
echo ***************************************************************

:: ### CONSTANTS & CONFIG ###
SET "TESTRUNNER_DIR=E:\Spel\Farming Simulator 2025\testRunner"
SET "GAME_DIR=E:\Spel\Farming Simulator 2025"
SET "MODS_DIR=E:\Spel\Farming Simulator 2022 Mods"


:: ### PREPARE PATHS ETC ###
SET origdir=%CD%

@REM SET DEPLOY_DIR=%~dp0
@REM SET "DEPLOY_DIR=&(echo %~dp0)"
@REM SET DEPLOY_DIR=%DEPLOY_DIR:\=;%

setlocal
  for %%d in (%~dp0.) do set DEPLOY_DIR=%%~fd
@REM   echo DEPLOY_DIR=%DEPLOY_DIR%
  for %%d in (%~dp0..) do set MASTER_DIR=%%~fd
@REM   echo MASTER_DIR=%MASTER_DIR%
@REM endlocal

SET "OUTPUT_DIR=%DEPLOY_DIR%\output"
SET "BASE_DIR=%MASTER_DIR%"

@REM SET "OUTPUT_DIR=output"
@REM SET "BASE_DIR=..\"
@REM if "%0"=="deploy\fsdt_build" ( SET "BASE_DIR=.\" & SET "OUTPUT_DIR=deploy\%OUTPUT_DIR%" ) 

SET "Action=%1"
SET "ModDirName=%2"
SET "ModPath=%BASE_DIR%\%ModDirName%"
SET "ModName=%3"
SET "MPPath=%4"

if "%ModDirName%"=="" ( echo. & echo ERROR: Paramter 1 'ModDirName' is empty & GOTO :Fail )
if "%ModName%"=="" ( echo. & echo WARNING: Paramter 2 'ModName' is empty, reusing ModDirName as ModName & SET "ModName=%ModDirName%")

SET "OutputArchive=%OUTPUT_DIR%\%ModName%.zip"
SET "OutputUpdateArchive=%OUTPUT_DIR%\%ModName%_update.zip"


echo.
echo Mod name: %ModName%
echo Mod directory name: %ModDirName%
echo Mod directory path: %ModPath%
echo Deploy path: %DEPLOY_DIR%
echo Output path: %OUTPUT_DIR%
echo Output archive path: %OutputArchive%



@REM echo Action method: %Method%

@REM @echo
@REM @echo Creating archive for mod '%MyPath%', please wait...
@REM @echo

@REM CD %MyPath%

@REM DEL ..\deploy\output\%ModName%.zip

@REM ..\deploy\7za.exe a ..\deploy\output\%ModName%.zip -tzip -mx=1 -x@..\deploy\exclude.txt -i@..\deploy\include.txt

@REM COPY /Y ..\deploy\output\%ModName%.zip ..\deploy\output\%ModName%_update.zip

@REM CD "%origdir%"


:: ### EXECTUTE MAIN COMMAND ###
SET /A Method=0
if "%Action%"=="build" ( SET /A Method=1 & CALL:Build )
if "%Action%"=="release" ( SET /A Method=2 & CALL:Deploy )
if "%Action%"=="test" ( SET /A Method=3 & Call:Test )
if "%Action%"=="mpbuild" ( SET /A Method=4 & Call:MPBuild )
if "%Action%"=="mpdeploy" ( SET /A Method=4 & Call:MPBuild )
@REM if %Method%==0 ( GOTO :Fail )

@REM if exist %ModPath%\ (
@REM   echo Yes 
@REM ) else (
@REM   echo No
@REM )


echo.
echo DONE

EXIT /B


:: ### FUNCTIONS ###

:Deploy <isDebug>
    @REM echo.
    @REM echo Executing command Deploy...

    CALL:Build
    CALL:Test
EXIT /B 0

:MPBuild <isDebug>
    @REM echo.
    @REM echo Executing command Deploy...

    SET "OutputMPArchive=%ModName%_mp.zip"

    CALL:Build
    COPY %OutputArchive% "%MODS_DIR%\%OutputMPArchive%"
    COPY %OutputArchive% "%MPPath%\%OutputMPArchive%"
EXIT /B 0

:Build <isDebug>
    echo.
    echo Executing command Build...

    if exist %OutputArchive% ( 
        echo Output file '%OutputArchive%' needs to be deleted
        DEL %OutputArchive%
    )

    PUSHD %ModPath%
    %DEPLOY_DIR%\7za.exe a %OutputArchive% -tzip -mx=1 -x@%DEPLOY_DIR%\exclude.txt
    @REM %DEPLOY_DIR%\7za.exe a %OutputArchive% -tzip -mx=1 -x@%DEPLOY_DIR%\exclude.txt -i@%DEPLOY_DIR%\include.txt
    POPD

    @REM %DEPLOY_DIR%\7za.exe a ..\deploy\output\%ModName%.zip -tzip -mx=1 -x@..\deploy\exclude.txt -i@..\deploy\include.txt 

    COPY /Y %OutputArchive% %OutputUpdateArchive%

EXIT /B 0

:Test 
    echo.
    echo Running tests...

    SET "TESTRUNNER_TEMP_DIR=%TESTRUNNER_DIR%\%ModName%\"
    SET "GAME_DIR_FS=%GAME_DIR:\=/%"
    SET "TESTRUNNER_TEMP_DIR_FS=%TESTRUNNER_TEMP_DIR:\=/%"

    echo.
    echo Game dir=%GAME_DIR%
    @REM echo Game dir (fixed)=%GAME_DIR_FS%
    echo Testrunner dir=%TESTRUNNER_DIR%
    echo Testrunner temp mod dir=%TESTRUNNER_TEMP_DIR%
    @REM echo Testrunner temp mod dir (fixed)=%TESTRUNNER_TEMP_DIR_FS%


    :: Pre-test cleanup
    if exist %TESTRUNNER_TEMP_DIR% ( 
        echo.
        echo Testrunner temp folder '%TESTRUNNER_TEMP_DIR%' not empty, needs to be cleaned
        rmdir /Q/S "%TESTRUNNER_TEMP_DIR%"
    ) else (
        echo.
        echo Testrunner temp folder '%TESTRUNNER_TEMP_DIR%' is clean, no action needed
    )


    :: Extract mod to a temp dir
    %DEPLOY_DIR%\7za.exe x %OutputArchive% -o"%TESTRUNNER_TEMP_DIR%"

    :: Run TestRunner on temp dir
    "%TESTRUNNER_DIR%\TestRunner_public.exe" "%TESTRUNNER_TEMP_DIR_FS%" -g "%GAME_DIR_FS%" --noPause
    @REM %TESTRUNNER_DIR%\TestRunner_public.exe "E:/Spel/SteamApps/common/Farming Simulator 19/TestRunner/%ModName%/" -g %GAME_DIR% --noPause

    :: Post-test cleanup
    if exist "%TESTRUNNER_TEMP_DIR%" ( 
        echo.
        echo Cleaning temp folder '%TESTRUNNER_TEMP_DIR%'
        rmdir /Q/S "%TESTRUNNER_TEMP_DIR%"
    )

    if exist "%TESTRUNNER_TEMP_DIR%" ( 
        echo.
        echo ERROR: Failed to clean temp folder '%TESTRUNNER_TEMP_DIR%'
    )


EXIT /B 0

:Fail 
    echo.
    echo FAILED: Unknown error 
EXIT /B -1