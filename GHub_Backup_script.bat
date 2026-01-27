@echo off

REM Licenced under The Unlicense license.

echo ********************************************************************************
echo.
echo                              G HUB SETTINGS BACKUP
echo.
echo               Files in the following locations will be copied:
echo.
echo               %%LocalAppData%%\LGHUB\ ^| %LocalAppData%\LGHUB\
echo               %%AppData%%\G HUB\      ^| %AppData%\G HUB\
echo               %%AppData%%\lghub\      ^| %AppData%\lghub\
echo               %%ProgramData%%\LGHUB\  ^| %ProgramData%\LGHUB\
echo.
echo               The backup is saved in a GHub_Backup folder in the
echo               user's Download folder. Separate subfolders are
echo               created for AppData and ProgramData. If a previous 
echo               backup is present, it will be replaced with the new one.
echo.
echo               To restore the backup, run the file GHub_Restore_script.bat.
echo               The backup files must be in the Downloads/GHub_Backup 
echo               with the same folder structure as when saved.
echo.
echo               This batch has been tested and works as intended, 
echo               but use it at your own discretion.
echo.
echo ********************************************************************************

:Ask
echo.
echo *** Would you like to proceed? [Y] Yes [N] No ***
set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“y” goto yesbackup
If /I “%INPUT%”==“n” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra

echo.
echo ##################################
echo     Invalid input. Type Y or N.   
echo ##################################
goto Ask

:yesbackup
echo.
echo The script will now shut down G Hub processes, delete 
echo a previous backup if present, and copy G Hub's files.
echo.

timeout /t 8 >nul

REM This section fetches the location of the Downloads folder for the current user so it can be used later on. 

FOR /F "USEBACKQ TOKENS=2,*" %%a IN (
	`REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /V {374DE290-123F-4565-9164-39C4925E467B}`
) DO (
	SET DOWNLOADS=%%b
)

REM The commands below shut down G Hub and associated processes so current settings files can be replaced.

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

REM The commands below delete a previous backup if present.

if exist "%DOWNLOADS%\GHub_Backup\AppData" (
goto RemoveBackup
) else (
if exist "%DOWNLOADS%\GHub_Backup\ProgramData" (
goto RemoveBackup
) else (
goto CreateBackup
)
)
:RemoveBackup 
echo.
echo.
echo ##################################
echo   Removing previous backup files
echo ##################################
timeout /t 2 >nul

echo.
if exist "%DOWNLOADS%\GHub_Backup\AppData" (
echo Removing %DOWNLOADS%\GHub_Backup\AppData from previous backup
rmdir /S /Q "%DOWNLOADS%\GHub_Backup\AppData"
timeout /t 1 >nul
)

if exist "%DOWNLOADS%\GHub_Backup\ProgramData" (
echo.
echo Removing %DOWNLOADS%\GHub_Backup\ProgramData from previous backup
rmdir /S /Q "%DOWNLOADS%\GHub_Backup\ProgramData"
timeout /t 1 >nul
)

REM The commands below copy G Hub's setting files to the backup folder

:CreateBackup
echo.
echo.
echo ##################################
echo          Creating backup
echo ##################################
timeout /t 2 >nul

echo.
echo Backing up %LocalAppData%\LGHUB
xcopy "%LocalAppData%\LGHUB\" "%DOWNLOADS%\GHub_Backup\AppData\Local\LGHUB\" /E /H /I /K /Y /Q
timeout /t 1 >nul
echo.
echo Backing up %AppData%\G HUB\
timeout /t 1 >nul
xcopy "%AppData%\G HUB\" "%DOWNLOADS%\GHub_Backup\AppData\Roaming\G HUB\" /E /H /I /K /Y /Q
timeout /t 1 >nul
echo.
echo Backing up %AppData%\lghub\
timeout /t 1 >nul
xcopy "%AppData%\lghub\" "%DOWNLOADS%\GHub_Backup\AppData\Roaming\lghub\" /E /H /I /K /Y /Q
echo.
echo Backing up %ProgramData%\LGHUB\
xcopy "%ProgramData%\LGHUB\" "%DOWNLOADS%\GHub_Backup\ProgramData\LGHUB\" /E /H /I /K /Y /Q
timeout /t 1 >nul

echo.
echo.
echo.
echo ********************************************************************************
echo.
echo                               ALL DONE 
echo.
echo    The backup will be in the GHub_Backup folder in your Downloads folder.
echo    And you didn't even need a Logitech account, let that sink in.
echo.
echo    To restore GHub's settings, make sure the backup files are in 
echo    Downloads/GHub_Backup and run the GHub_Restore_script.bat file.
echo.
echo ********************************************************************************
echo.
timeout /t 1 >nul
pause
exit

:no
echo. 
echo ********************************************************************************
echo                     No action was taken, shutting down.
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