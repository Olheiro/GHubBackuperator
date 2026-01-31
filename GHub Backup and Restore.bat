@echo off

REM Licenced under The Unlicense license.

REM This batch script must be run as administrator to delete and write files in ProgramData. 
REM It will automatically request elevation if needed.

setlocal EnableDelayedExpansion
fsutil Dirty Query %SystemDrive% > nul && goto:[RunAs]
echo CreateObject^("Shell.Application"^). ^
ShellExecute "%~0","+","","RunAs",1 > "%Temp%\+.vbs" && "%Temp%\+.vbs" & Exit
:[RunAs]

REM This section fetches the location of the Downloads folder for the current user so it can be used later on. 

FOR /F "USEBACKQ TOKENS=2,*" %%a IN (
	`REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /V {374DE290-123F-4565-9164-39C4925E467B}`
) DO (
	SET DOWNLOADS=%%b
)

set %question=0
echo.
echo.
echo ********************************************************************************
echo.
echo                                G HUB BACKUPERATOR
echo.
echo               This utility allows Logitech G Hub's settings and profiles
echo               to be backed up and restored without creating a Logitech
echo               account. The backup can prevent data loss or allow moving 
echo               G Hub to a new PC.
echo.
echo               This batch has been tested and works as intended 
echo               with G Hub version 2025.9.814157, but use it at your own 
echo               discretion. I'm not responsible for any issues caused by
echo               the use of this script.
echo. 
echo ********************************************************************************

:Ask
echo.
echo *** Would you like to [C] CREATE a backup, [R] RESTORE a backup or [E] exit? ***

set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“c” goto Backup
If /I “%INPUT%”==“r” goto Restore
If /I “%INPUT%”==“e” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra

echo.
echo ######################################
echo     Invalid input. Type C, R or E.
echo ######################################
goto Ask


:Backup
set %question=1
echo.
echo.
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
echo               To restore the backup, run this script again and choose
echo               RESTORE at the initial prompt. The backup files must be
echo               in Downloads/GHub_Backup with the same folder structure 
echo               as when saved.
echo.
echo ********************************************************************************

:AskBackup
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
goto AskBackup

:yesbackup
echo.
echo You have chosen wisely.
echo.
echo The script will now shut down G Hub processes, delete 
echo a previous backup if present, and copy G Hub's files.
echo.

timeout /t 8 >nul

goto Shutdown


REM The section below shuts down G Hub and associated processes so current settings files can be replaced.

:Shutdown
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

if %question%==1 goto DeleteBackup
if %question%==2 goto DeleteSettings


REM The section below deletes a previous backup if present.

:DeleteBackup
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

goto CreateBackup


REM The section below copies G Hub's setting files to the backup folder

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

goto AllDoneBackup

:AllDoneBackup
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



:Restore

set %question=2
echo.
echo.
echo ********************************************************************************
echo.
echo                           G HUB SETTINGS RESTORE
echo.
echo               This will restore G Hub's settings files from a folder
echo               called GHub_Backup in the user's Download folder saved
echo               using the CREATE backup option of this bach file.
echo.
echo           ###########################################################
echo                       IF THE BACKUP FILES ARE NOT FOUND IN
echo                Downloads/GHub_Backup, THE RESTORE CANNOT PROCEED
echo           ###########################################################
echo.
echo ********************************************************************************

:AskRestore
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
goto AskRestore

:yesrestore
echo.
echo The script will now shut down G Hub processes, verify a backup
echo is present, delete current settings, and restore previoulsy saved 
echo G Hub settings and profiles.
echo.

timeout /t 8 >nul

goto VerifyBackup


REM The section below checks for an existing full backup and delete G Hub's current setting files if they exist.

:VerifyBackup
echo.
echo.
echo ##################################
echo       Verifying backup files
echo ##################################
timeout /t 2 >nul

if exist "%DOWNLOADS%\GHub_Backup\ProgramData\LGHUB\" (
echo.
echo %DOWNLOADS%\GHub_Backup\ProgramData\LGHUB\ found
timeout /t 1 >nul
) else (
echo.
echo %DOWNLOADS%\GHub_Backup\ProgramData\LGHUB\ not found
timeout /t 4 >nul
goto MissingRestore
)

if exist "%DOWNLOADS%\GHub_Backup\AppData\Local\LGHUB" (
echo.
echo %DOWNLOADS%\GHub_Backup\AppData\Local\LGHUB\ found
timeout /t 1 >nul
) else (
echo.
echo %DOWNLOADS%\GHub_Backup\AppData\Local\LGHUB\ not found
timeout /t 4 >nul
goto MissingRestore
)

if exist "%DOWNLOADS%\GHub_Backup\AppData\Roaming\lghub\" (
echo.
echo %DOWNLOADS%\GHub_Backup\AppData\Roaming\lghub\ found
timeout /t 1 >nul
) else (
echo.
echo %DOWNLOADS%\GHub_Backup\AppData\Roaming\lghub\ not found
timeout /t 4 >nul
goto MissingRestore
)

if exist "%DOWNLOADS%\GHub_Backup\AppData\Roaming\G HUB\" (
echo.
echo %DOWNLOADS%\GHub_Backup\AppData\Roaming\G HUB\ found
timeout /t 1 >nul
) else (
echo.
echo %DOWNLOADS%\GHub_Backup\AppData\Roaming\G HUB\ not found
timeout /t 4 >nul
goto MissingRestore
)

goto Shutdown


REM The section below removes existing G Hub settings

:DeleteSettings
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

goto RestoreBackup


REM The section below copies G Hub's settings previouls backed up to their respective system folders.
REM The files must be in a folder named "GHub_backup" in the Downloads folder and properly separated into subfolders.

:RestoreBackup
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

goto AllDoneRestore

:AllDoneRestore
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

if %question%==0 goto Ask
if %question%==1 goto AskBackup
if %question%==2 goto AskRestore
