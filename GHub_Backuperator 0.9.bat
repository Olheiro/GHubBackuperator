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
echo               with G Hub version 2026.1.828355, but use it at your own 
echo               discretion. I'm not responsible for any issues caused by
echo               the use of this script.
echo. 
echo ********************************************************************************

:Ask
set %question=0
echo.
echo  *** [C] CREATE a backup ^| [R] RESTORE a backup ^| [Q] QUIT? ***

set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“c” goto Backup
If /I “%INPUT%”==“r” goto Restore
If /I “%INPUT%”==“q” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra

echo.
echo.
echo ######################################
echo     Invalid input. Type C, R or Q.
echo ######################################
goto Ask


:Backup

set DefaultFolder=%Downloads%\GHub_Backup
set CustomFolder=%Downloads%\GHub_Backup
set BackupFolder=%Downloads%\GHub_Backup

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
echo               The default backup location is Downloads\GHub_Backup,
echo               Separate AppData and ProgramData subfolders are created 
echo               inside the folder selected as the backup location.
echo.
echo               If a previous backup is present, it will be replaced with
echo               the new one.
echo.
echo               To restore the backup, run this script again and choose
echo               RESTORE at the initial prompt.
echo.
echo ********************************************************************************


:AskBackup
set %question=1
echo.
echo *** Would you like to proceed? [Y] Yes [N] No ***
set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“y” goto ChooseBackup
If /I “%INPUT%”==“n” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra
echo.
echo.
echo ##################################
echo     Invalid input. Type Y or N.   
echo ##################################
goto AskBackup

:ChooseBackup
echo.
echo.
echo ##################################
echo. 
echo   The default backup folder is:
echo. 
echo   %Downloads%\GHub_Backup
echo.
echo ##################################
echo.
echo  *** Use the [D] default folder ^| [C] Choose a custom folder ^| [Q] Quit ***


:AskBackupFolder
set %question=2
echo.
set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“d” goto StartBackup
If /I “%INPUT%”==“c” goto ChooseBackupFolder
If /I “%INPUT%”==“q” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra
echo.
echo.
echo ##################################
echo   Invalid input. Type D, C or Q.   
echo ##################################
goto AskBackupFolder


:ChooseBackupFolder
echo.
echo Select the folder where G Hub's backup will be saved.
timeout /t 3 >nul

REM This command opens a file selection dialog and retrieves the path of the open folder whether or not a file in selected

SET "PScommand="POWERSHELL Add-Type -AssemblyName System.Windows.Forms; $FolderBrowse = New-Object System.Windows.Forms.OpenFileDialog -Property @{ValidateNames = $false;CheckFileExists = $false;RestoreDirectory = $true;FileName = 'Select folder';};$null = $FolderBrowse.ShowDialog();$FolderName = Split-Path -Path $FolderBrowse.FileName;Write-Output $FolderName""
FOR /F "usebackq tokens=*" %%Q in (`%PScommand%`) DO (
REM    ECHO %%Q was selected 

SET CustomFolder=%%Q
)

if "%CustomFolder%"=="C:\" (
echo.
echo.
echo ##################################
echo         %CustomFolder% is not allowed
echo    Select a different location   
echo ##################################
timeout /t 8 >nul
goto ChooseBackupFolder
) else (
if "%CustomFolder%"=="%DefaultFolder%" (
echo.
echo No custom folder was selected.
echo.
echo Backup will be saved in %DefaultFolder%
set BackupFolder=%DefaultFolder%
timeout /t 2 >nul
goto ConfirmBackupFolder
) else (
echo.
echo Backup will be saved in %CustomFolder%
set BackupFolder=%CustomFolder%
timeout /t 2 >nul
goto ConfirmBackupFolder
)
)


:ConfirmBackupFolder
set %question=3
echo. 
echo  *** [C] Confirm ^| [S] Select another ^| [Q] Quit ***
echo.
set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“c” goto StartBackup
If /I “%INPUT%”==“s” goto ChooseBackupFolder
If /I “%INPUT%”==“q” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra
echo.
echo.
echo ##################################
echo     Invalid input. Type Y or N.   
echo ##################################
goto ConfirmBackupFolder


:StartBackup
echo.
echo You have chosen wisely.
echo.
echo The script will now shut down G Hub processes, delete 
echo a previous backup if present, and copy G Hub's files to
echo %BackupFolder%
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

if %question%==2 goto DeleteBackup
if %question%==3 goto DeleteBackup
if %question%==5 goto DeleteSettings
if %question%==6 goto DeleteSettings


REM The section below deletes a previous backup if present.

:DeleteBackup
if exist "%BackupFolder%\AppData" (
goto RemoveBackup
) else (
if exist "%BackupFolder%\ProgramData" (
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
if exist "%BackupFolder%\AppData" (
echo Removing %BackupFolder%\AppData from previous backup
rmdir /S /Q "%BackupFolder%\AppData"
timeout /t 1 >nul
)

if exist "%BackupFolder%\ProgramData" (
echo.
echo Removing %BackupFolder%\ProgramData from previous backup
rmdir /S /Q "%BackupFolder%\ProgramData"
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
xcopy "%LocalAppData%\LGHUB\" "%BackupFolder%\AppData\Local\LGHUB\" /E /H /I /K /Y /Q
timeout /t 1 >nul
echo.
echo Backing up %AppData%\G HUB\
timeout /t 1 >nul
xcopy "%AppData%\G HUB\" "%BackupFolder%\AppData\Roaming\G HUB\" /E /H /I /K /Y /Q
timeout /t 1 >nul
echo.
echo Backing up %AppData%\lghub\
timeout /t 1 >nul
xcopy "%AppData%\lghub\" "%BackupFolder%\AppData\Roaming\lghub\" /E /H /I /K /Y /Q
echo.
echo Backing up %ProgramData%\LGHUB\
xcopy "%ProgramData%\LGHUB\" "%BackupFolder%\ProgramData\LGHUB\" /E /H /I /K /Y /Q
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
echo    The backup will be in %BackupFolder%.
echo    And you didn't even need a Logitech account, let that sink in.
echo.
echo    To restore GHub's settings, run this batch file again and choose RESTORE.
echo.
echo ********************************************************************************
echo.
timeout /t 1 >nul
pause
exit

REM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:Restore

set DefaultFolder=%Downloads%\GHub_Backup
set CustomFolder=%Downloads%\GHub_Backup
set BackupFolder=%Downloads%\GHub_Backup

echo.
echo.
echo ********************************************************************************
echo.
echo                           G HUB SETTINGS RESTORE
echo.
echo               This will restore G Hub's settings files from a previous
echo               backup. The default backup location is 
echo               %Downloads%\GHub_Backup 
echo               or you can choose where to copy from. 
echo.
echo               The folder selected must be the one that contains the 
echo               AppData and ProgramData subfolders, e.g., open the 
echo               GHub_Backup folder in the selection dialog if the default
echo               location was used for the backup.
echo.
echo ********************************************************************************

:AskRestore
set %question=4
echo.
echo *** Would you like to proceed? [Y] Yes [N] No ***
set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“y” goto ChooseRestore
If /I “%INPUT%”==“n” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra

echo.
echo ##################################
echo     Invalid input. Type Y or N.
echo ##################################
goto AskRestore




:ChooseRestore
echo.
echo.
echo ##################################
echo. 
echo   The default backup folder is:
echo. 
echo   %Downloads%\GHub_Backup
echo.
echo ##################################
echo.
echo  *** Use the [D] default folder ^| [C] Choose a custom folder ^| [Q] Quit ***


:AskRestoreFolder
set %question=5
echo.
set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“d” goto StartRestore
If /I “%INPUT%”==“c” goto ChooseRestoreFolder
If /I “%INPUT%”==“q” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra
echo.
echo.
echo ##################################
echo   Invalid input. Type D, C or Q.   
echo ##################################
goto AskRestoreFolder


:ChooseRestoreFolder
echo.
echo Select the folder where G Hub's backup was saved.
echo.
echo The folder with AppData and ProgramData must be opened in the dialog.
timeout /t 3 >nul

REM This command opens a file selection dialog and retrieves the path of the open folder whether or not a file in selected

SET "PScommand="POWERSHELL Add-Type -AssemblyName System.Windows.Forms; $FolderBrowse = New-Object System.Windows.Forms.OpenFileDialog -Property @{ValidateNames = $false;CheckFileExists = $false;RestoreDirectory = $true;FileName = 'Select folder';};$null = $FolderBrowse.ShowDialog();$FolderName = Split-Path -Path $FolderBrowse.FileName;Write-Output $FolderName""
FOR /F "usebackq tokens=*" %%Q in (`%PScommand%`) DO (
REM    ECHO %%Q was selected 

SET CustomFolder=%%Q
)

if "%CustomFolder%"=="C:\" (
echo.
echo.
echo ##################################
echo         %CustomFolder% is not allowed
echo    Select a different location   
echo ##################################
timeout /t 8 >nul
goto ChooseRestoreFolder
) else (
if "%CustomFolder%"=="%DefaultFolder%" (
echo.
echo No custom folder was selected.
echo.
echo Backup will be restored from %DefaultFolder%
set BackupFolder=%DefaultFolder%
timeout /t 2 >nul
goto ConfirmRestoreFolder
) else (
echo.
echo Backup will be restored from %CustomFolder%
set BackupFolder=%CustomFolder%
timeout /t 2 >nul
goto ConfirmRestoreFolder
)
)


:ConfirmRestoreFolder
set %question=6
echo. 
echo  *** [C] Confirm ^| [S] Select another ^| [Q] Quit ***
echo.
set INPUT=
set /P INPUT=Type input: %=%
If /I “%INPUT%”==“c” goto StartRestore
If /I “%INPUT%”==“s” goto ChooseRestoreFolder
If /I “%INPUT%”==“q” goto no
If /I “%INPUT%”==“upupdowndownleftrightleftrightba” goto contra
echo.
echo.
echo ##################################
echo   Invalid input. Type C, S or Q.   
echo ##################################
goto ConfirmBackupFolder


:StartRestore
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

if exist "%BackupFolder%\ProgramData\LGHUB\" (
echo.
echo %BackupFolder%\ProgramData\LGHUB\ found
timeout /t 1 >nul
) else (
echo.
echo %BackupFolder%\ProgramData\LGHUB\ not found
timeout /t 4 >nul
goto MissingRestore
)

if exist "%BackupFolder%\AppData\Local\LGHUB" (
echo.
echo %BackupFolder%\AppData\Local\LGHUB\ found
timeout /t 1 >nul
) else (
echo.
echo %BackupFolder%\AppData\Local\LGHUB\ not found
timeout /t 4 >nul
goto MissingRestore
)

if exist "%BackupFolder%\AppData\Roaming\lghub\" (
echo.
echo %BackupFolder%\AppData\Roaming\lghub\ found
timeout /t 1 >nul
) else (
echo.
echo %BackupFolder%\AppData\Roaming\lghub\ not found
timeout /t 4 >nul
goto MissingRestore
)

if exist "%BackupFolder%\AppData\Roaming\G HUB\" (
echo.
echo %BackupFolder%\AppData\Roaming\G HUB\ found
timeout /t 1 >nul
) else (
echo.
echo %BackupFolder%\AppData\Roaming\G HUB\ not found
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
xcopy "%BackupFolder%\AppData\Local\LGHUB\" "%LocalAppData%\LGHUB\" /E /H /I /K /Y /Q
timeout /t 1 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo Restoring AppData\Roaming\lghub\
xcopy "%BackupFolder%\AppData\Roaming\lghub\" "%AppData%\lghub\" /E /H /I /K /Y /Q
timeout /t 1 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo Restoring AppData\Roaming\G HUB\
xcopy "%BackupFolder%\AppData\Roaming\G HUB\" "%AppData%\G HUB\" /E /H /I /K /Y /Q
timeout /t 1 >nul

tasklist /fi "imagename eq lghub_agent.exe" |find ":" >nul
if errorlevel 1 taskkill /f /im "lghub_agent.exe" >nul

echo.
echo Restoring ProgramData\LGHUB\
xcopy "%BackupFolder%\ProgramData\LGHUB\" "%ProgramData%\LGHUB\" /E /H /I /K /Y /Q
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
echo.
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
if %question%==2 goto AskBackupFolder
if %question%==3 goto ConfirmBackupFolder
if %question%==4 goto AskRestore
if %question%==5 goto AskRestoreFolder
if %question%==6 goto ConfirmRestoreFolder

