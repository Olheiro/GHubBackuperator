@echo off

REM Licenced under The Unlicense license.

REM This batch script must be run as administrator to delete  and write files in ProgramData. 
REM It will automatically request elevation if needed.

setlocal EnableDelayedExpansion
fsutil Dirty Query %SystemDrive% > nul && goto:[RunAs]
echo CreateObject^("Shell.Application"^). ^
ShellExecute "%~0","+","","RunAs",1 > "%Temp%\+.vbs" && "%Temp%\+.vbs" & Exit
:[RunAs]

echo ********************************************************************************
echo.
echo                           G HUB SETTINGS RESTORE
echo.
echo               This batch file will restore G Hub's settings files
echo               from a folder called GHub_Backup in the user's 
echo               Download folder saved with the GHub_Backup_script.bat file.
echo.
echo           ###########################################################
echo                       IF THE BACKUP FILES ARE NOT FOUND IN
echo                Downloads/GHub_Backup, THE RESTORE CANNOT PROCEED
echo           ###########################################################
echo.
echo               This batch file has been tested and works as intended, 
echo               but use at your own discretion. 
echo.
echo ********************************************************************************

:Ask
echo.
echo *** Would you like to proceed? [Y] Yes [N] No ***
set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“y” goto yesrestore
If /I “%INPUT%”==“n” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra

echo.
echo ##################################
echo     Invalid input. Type Y or N.
echo ##################################
goto Ask

:yesrestore
echo.
echo The script will now shut down G Hub processes, verify a backup
echo is present, delete current settings, and restore G Hub's settings
echo previoulsy saved with the GHub_Backup_script.bat file.
echo.

timeout /t 8 >nul

REM This section fetches the location of the Downloads folder for the current user so it can be used later on.

FOR /F "USEBACKQ TOKENS=2,*" %%a IN (
`REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /V {374DE290-123F-4565-9164-39C4925E467B}`
) DO (
SET DOWNLOADS=%%b
)

REM The commands below check for an existing full backup and delete G Hub's current setting files if they exist.

echo.
echo.
echo ##################################
echo       Verifying backup files
echo ##################################
timeout /t 2 >nul

if exist "%DOWNLOADS%\GHub_Backup\AppData\Local\LGHUB" (
echo.
echo %DOWNLOADS%\GHub_Backup\AppData\Local\LGHUB found
timeout /t 1 >nul
) else (
echo %DOWNLOADS%\GHub_Backup\AppData\Local\LGHUB not found
timeout /t 4 >nul
goto MissingRestore
)

if exist "%DOWNLOADS%\GHub_Backup\AppData\Roaming\lghub\" (
echo.
echo %DOWNLOADS%\GHub_Backup\AppData\Roaming\lghub\ found
timeout /t 1 >nul
) else (
echo %DOWNLOADS%\GHub_Backup\AppData\Roaming\lghub\ not found
timeout /t 4 >nul
goto MissingRestore
)

if exist "%DOWNLOADS%\GHub_Backup\AppData\Roaming\G HUB\" (
echo.
echo %DOWNLOADS%\GHub_Backup\AppData\Roaming\G HUB\ found
timeout /t 1 >nul
) else (
echo %DOWNLOADS%\GHub_Backup\AppData\Roaming\G HUB\ not found
timeout /t 4 >nul
goto MissingRestore
)

if exist "%DOWNLOADS%\GHub_Backup\ProgramData\LGHUB\" (
echo.
echo %DOWNLOADS%\GHub_Backup\ProgramData\LGHUB\ found
timeout /t 1 >nul
) else (
echo %DOWNLOADS%\GHub_Backup\ProgramData\LGHUB\ not found
timeout /t 4 >nul
goto MissingRestore
)

REM The commands below shut down G Hub and associated processes so the settings files can be deleted and/or overwritten.

set %shutdisplay=0
tasklist /fi "imagename eq lghub.exe" |find ":" >nul
if errorlevel 1 (
set %shutdisplay=1
echo.
echo.
echo ##################################
echo Shutting down running G Hub files
echo ##################################
timeout /t 2 >nul
echo.
echo Shutting down lghub.exe
timeout /t 1 >nul
taskkill /f /im "lghub.exe" >nul
) else (
goto ShutAgent
)

:ShutAgent
tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 (
if %shutdisplay%==1 (
echo.
echo Shutting down lghub_agent.exe
timeout /t 1 >nul
taskkill /f /im lghub_agent.exe >nul
) else (
set %shutdisplay=1
echo.
echo.
echo ##################################
echo Shutting down running G Hub files
echo ##################################
timeout /t 2 >nul
echo.
echo Shutting down lghub_agent.exe
timeout /t 1 >nul
taskkill /f /im "lghub_agent.exe" >nul
) 
) else (
goto ShutTray
)

:ShutTray
tasklist /fi "imagename eq lghub_system_tray.exe" |find ":" >nul
if errorlevel 1 (
if %shutdisplay%==1 (
echo.
echo Shutting down lghub_system_tray.exe
timeout /t 1 >nul
taskkill /f /im lghub_system_tray.exe >nul
) else (
set %shutdisplay=1
echo.
echo.
echo ##################################
echo Shutting down running G Hub files
echo ##################################
timeout /t 2 >nul
echo.
echo Shutting down lghub_system_tray.exe
timeout /t 1 >nul
taskkill /f /im "lghub_system_tray.exe" >nul
)
)

REM taskkill /F /IM "lghub_updater.exe"
REM lghub_updater runs as a system service and cannot be terminated with taskkill. It will not interefere in the process.

timeout /t 1 >nul

echo.
echo.
echo ##################################
echo     Deleting existing settings
echo ##################################
timeout /t 2 >nul

echo.
echo Removing %LocalAppData%\LGHUB\
rmdir /S /Q "%LocalAppData%\LGHUB\"
timeout /t 1 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo Removing %AppData%\lghub\
rmdir /S /Q "%AppData%\lghub\"
timeout /t 1 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo Removing %AppData%\G HUB\
rmdir /S /Q "%AppData%\G HUB\"
timeout /t 1 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo Removing %ProgramData%\LGHUB\
rmdir /S /Q "%ProgramData%\LGHUB\"
timeout /t 3 >nul

REM The commands below copy G Hub's settings backed up with GHub_backup_script.bat to their respective system folders. The files must be in a folder named "GHub_backup" in the Downloads folder and properly separated into subfolders.

echo.
echo.
echo ##################################
echo          Restoring backup
echo ##################################
timeout /t 2 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul
echo.
echo Restoring AppData\Local\LGHUB\
xcopy "%DOWNLOADS%\GHub_Backup\AppData\Local\LGHUB\" "%LocalAppData%\LGHUB\" /E /H /I /K /Y /Q
timeout /t 1 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo Restoring AppData\Roaming\lghub\
xcopy "%DOWNLOADS%\GHub_Backup\AppData\Roaming\lghub\" "%AppData%\lghub\" /E /H /I /K /Y /Q
timeout /t 1 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo Restoring AppData\Roaming\G HUB\
xcopy "%DOWNLOADS%\GHub_Backup\AppData\Roaming\G HUB\" "%AppData%\G HUB\" /E /H /I /K /Y /Q
timeout /t 1 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo Restoring ProgramData\LGHUB\
xcopy "%DOWNLOADS%\GHub_Backup\ProgramData\LGHUB\" "%ProgramData%\LGHUB\" /E /H /I /K /Y /Q
timeout /t 2 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo ********************************************************************************
echo.
echo                               ALL DONE 
echo.
echo    Your backup of G Hub's settings has been restored. 
echo    And you didn't even need a Logitech account, let that sink in.
echo.
echo    If you restored a very old backup, there may be an error when G Hub
echo    is opened. Install G Hub again and choose to transfer current settings
echo    and G Hub will work normally, at least as good as Logitech managed.
echo.
echo ********************************************************************************
echo.
pause
exit

:no
echo. 
echo ********************************************************************************
echo.
echo                     No action was taken, shutting down.
echo.
echo ********************************************************************************
echo.
pause
exit

:MissingRestore
echo.
echo ********************************************************************************
echo.
echo              Backup files not found, restore will not be performed.
echo                 G Hub will use existing settings when launched.
echo.
echo ********************************************************************************
echo.
pause
exit

:contra
timeout /t 3 >nul
echo.
echo                                  .;++++++++++++++++:.           
echo                                 .;xxxxxxxxxxxxxxxx+..           
echo                                .:+xxxxxxxxxxxxxxxx:.            
echo                                .;xxxxxxxxxxxxxxxx;..            
echo                               .;xxxxxxxxxxxxxxxx+..             
echo                              .:xxxxxxxxxxxxxxxx+..              
echo                            ..;xxxxxxxxxxxxxxxx;...              
echo                         ...;xxxxxxxxxxxxxxx+;..                 
echo                .......:;+xxxxxxxxxxxxx++;.......................
echo            ...:+xxxxxxxxxxxxxx+:...         .:;;;;;;;;;;;;;;;;;.
echo          ..:xxxxxxxxxxxxxxxx;.             .:;;;;;;;;;;;;;;;;;..
echo          .xxxxxxxxxxxxxxxxx:.              .:;;;;;;;;;;;;;;;;:. 
echo         .xxxxxxxxxxxxxxxxx:.              .:;;;;;;;;;;;;;;;;:.. 
echo        .xxxxxxxxxxxxxxxxx;.              .:;;;;;;;;;;;;;;;;:... 
echo        +xxxxxxxxxxxxxxxx;..             .:;;;;;;;;;;;;;;;;:..   
echo       :xxxxxxxxxxxxxxxx+..            .:;;;;;;;;;;;;;;;;:...    
echo      .xxxxxxxxxxxxxxxxx;.        ...:;;;;;;;;;;;;;;;;:....      
echo      .::::::::::::::::.....::;;;;;;;;;;;;;;:..........          
echo                       ..:;;;;;;;;;;;;;;;:....                   
echo                     ..:;;;;;;;;;;;;;;;;...                      
echo                    ..;;;;;;;;;;;;;;;;:..                        
echo                   ..;;;;;;;;;;;;;;;;;..                         
echo                  ..:;;;;;;;;;;;;;;;;:..                         
echo                  .:;;;;;;;;;;;;;;;;:..                          
echo                 ..;;;;;;;;;;;;;;;;;..                           
echo                ..:::::::::::::::::..                            

goto Ask