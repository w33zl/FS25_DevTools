@ECHO OFF

:: ACTION (release = build+test | build = create archive | test = only run test)
SET "ACTION=build"

:: MOD FOLDER NAME (e.g. FS22_YOUR-MOD-NAME)
SET "FOLDER_NAME=FS25_000_DevTools"

:: MOD OUTPUT NAME (e.g. FS22_YOUR-MOD-NAME, defaults to the mod folder name)
SET "OUTPUT_NAME=%FOLDER_NAME%"

:: EXECUTE
%~dp0fsdt_build %ACTION% %FOLDER_NAME% %OUTPUT_NAME%

