# GHubBackuperator
Backup and restore Logitech G Hub's settings without a Logitech account.
Eat it, corpos!


------------------
G Hub Backuperator
------------------

G Hub Backuperator backs up and restores Logitch G Hub's settings and profiles
in Windows. A backup can be useful in case of drive failure, reformats or to
transfer settings and profiles to a new computer.

G Hub only allows backing up to Logitech's cloud storage, which requires 
creating an account. Files can be copied and restored manually, but that's
cumbersome and prone to mistakes. This utility automates those processes 
over a few seconds with no need to dive into system folders.

The settings files backed up are located in %LocalAppData%\LGHUB\,
%AppData%\G HUB\, %AppData%\lghub\ and %ProgramData%\LGHUB\ and are saved in
Downloads/GHub_Backup by default.

The backup can be saved to or restored from the default Downloads\GHub_Backup
or a custom location can be chosen.

The batch file must be run as administrator so it can have write access to 
ProgramData. It automatically requests UAC elevation if launched without
administrator priviledge.


-------
LICENSE
-------
This work is licensed under The Unlicense.

It's yours. It's ours. Do with it whatever you want. Beat it with a hammer,
paint if orange, plant it in a vase, put it in the underwear drawer to add a
pleasant scent, throw it at the wall to see if it sticks, I don't care. If you
decide to swallow it, try drinking water along to wash it down. Just don't use
it for evil if you ever find a way to. You jerk.


----------
DISCLAIMER
----------
This utility has been tested and shown to work, but use it at your own
discretion. I'm not responsible for data loss or any issue caused by the use of
this utility, including, but not limited to, due to user error and future
updates to G Hub. I might be available to hear your sad story, but I do not 
guarantee I'll be able to soothe your pain.


------------
INSTRUCTIONS
------------

The utility consists of a batch file called GHub_Backuperator.bat.

The batch file can be executed from anywhere on the user's drive, including
removable media. 

The batch file must run as administrator to have write access in ProgramData. 
The script will show a UAC elevation prompt when launched as a regular user.


** To backup G Hub's settings:

1. Execute GHub_Backuperator.bat as administrator.

1a. Confirm the UAC elevation prompt if the batch is not run as administrator.

2. Choose C at the prompt to create a backup. Or not, do whatever you want,
   I'm not yout real dad anyway.

3. Choose Y in the next prompt to proceed.

4. Choose D to create the backup in Downloads\GHub_Backup or C to choose a 
   custom location. C:\ is not allowed.

4a. If using a custom location, select the folder where the AppData and
    ProgramData settings folders will be saved to.

4b. Choose C to confirm the custom backup folder or S to select another one.

5. Wait until the backup is complete.

6. Launch G Hub again if it was running.

The backup will be in Downloads/GHub_Backup or in the custom folder selected
split into AppData and ProgramData folders.


** To restore G Hub's settings from a backup:

1. Make sure the backup files are in the default Downloads\GHub_Backup or a
   custom folder with the same subfolder structure as when copied, i.e.,
   split into AppData and ProgramData.

2. Execute GHub_Backuperator.bat.

3. Choose R in the prompt to restore a backup.

4. Choose Y in the next prompt to proceed.

5. Choose D to use the default Downloads\GHub_Backup folder or C to select a
   custom folder. Restoring from C:\ is not allowed.

5a. If restoring from a custom folder, open it in the dialog. The folder
    containing the AppData and ProgramData folders must be selected, e.g.,
    Open the GHub_Backup folder if the backup was saved in default location. 

5b. Choose C to confirm the custom restore folder or S to select another one.

6. Press Y at the next prompt to proceed. You'd better or you'll need to 
   manually recreate each profile again in G Hub.

7. Wait until the backup is restored.

8. Launch G Hub.


------------
KNOWN ISSUES
------------

If the backup restored is very old, it may cause G Hub to show errors and
potentially bootloop.

If that happens, follow these steps in order until G Hub runs normally:

1. Don't panic and bring a towel. 

2. Terminate all G Hub processes in Task Manager and launch G Hub again.

3. Restart Windows (you can skip step 2 if you're not comfotable with it).

4. Reinstall G Hub and choose to transfer your settings so it repairs files
   that are incompatible with the version of the backup or adds files required
   by the new version.


---
FAQ
---

1. Wow!
*  Yeah.

2. Why?
*  A mix of frustrated with Logitech, mad at G Hub, bored, and hyperfocus.

3. Will you make a Mac version?
*  The only time I use a mac is when it rains.

4. Will you make a Linux version?
*  Be honest, you know G Hub is not avaliable for Linux, you're just asking that
   because you are legally mandated to tell people you use Linux.

5. Your code is shit!
*  I'm glad there are good enough coders to not only notice that but to also
   improve it. Wipe the cheetos dust off your fingies and get to it.

6. Hamburgers or hot dogs?
*  Hamburgers.

7. WHY DO YOU HATE HOT DOGS? YOU MONSTER!
*  Don't feed the trolls.

8. Do you have plans for improvements?
*  I already added a way to choose the backup location or where to restore from
   as planned. Longer term could include turning this utility
   into an executable with a GUI.

9. I want to request a feature.
*  And I want world peace, that doesn't mean it will happen. Drop a note anyway,
   I might get to it before I get distracted by some jingling keys.

10. I want to report a bug.
*   Go ahead, it's not like I need to grant you authorization or anything.

11. How can I reward you?
*   Thanks would be nice. If you want to give me money, we could meet in a dark
    alley after business hours. Bring unmarked, non sequential notes in an
    opaque, non-descript plastic bag and wear something that doesn't contrast too
    much with red. I'll always accept nudes if that's your thing.

12. Hotel?
*   Trivago.


---------------
VERSION HISTORY
---------------

֍ 0.1 
- @echo off

֍ 0.2
- Utility created as two separate batch files that copy G Hub setting files to
  a directory in my own Downloads folder and restore files from that location.

֍ 0.201
- Added files from C:\ProgramData to backup.

֍ 0.205
- Code optmized and commented.

֍ 0.3
- Added defining the backup location using the C:\Users\%username&\Downloads\
  format instead of using my own username.
- Added fecthing AppData and ProgramData locations using environment variables
  instead of the locations in my own drive.

֍ 0.31 
- Added automatic detection of the exact Download folder location for more 
  flexibility with custom locations and to acommodate users running Windows in
  a language that doesn't use the word Downloads for that folder.

֍ 0.4
- Code optimized and cleaned up.

֍ 0.5
- Fixed issue with detecting the Download folder's location.
- Added automatically terminating G Hub and associated processes to prevent
  access violation errors when restoring backups.

֍ 0.505
- Added displaying information such as where the backup files are saved at the
  start of the batch files.

֍ 0.508
- Added pauses requiring a keypress to proceed after the initial information
  prompt and at the end of the script.
- Added information at the end of the scripts.
- Improved formatting of information prompts.
- Revised the initial text.

֍ 0.51
- Added automatic UAC elevation request to the restore batch so users don't
  need to run it as administrator. Elevation is required to delete files from
  and copy files to %ProgramData%. If the batch is launched with administrator
  rights, no elevation prompt is shown.

֍ 0.6
- Major script structure revision.
- Added prompt to proceed or cancel after the initial description.

֍ 0.61
- Added information that no action was taken when choosing to not proceed and
  of invalid input.
- Added displaying actions being taken during the backup and restore process.

֍ 0.62
- Added a list of directories that are part of the backup to the initial text
  of the backup script.
- Changed visual elements for uniformity.

֍ 0.63
- Added >nul to process termination commands.
- Removed command to terminate the lghub_updater.exe process, which runs as a
  service and cannot be terminated with a simple taskkill command. The process
  does not interfere with the backup or restore procedures.
- Added intervals after information prompts and between actions to facilitate
  following execution.

֍ 0.64
- Added descriptions of the actions being performed broken down into individual
  commands.
- Added easter egg.

֍ 0.65
- Changed inital information to include both the variable location and the
  exact directory in the local Windows installation.
- Added the directories being copied or removed at each step of the backup and
  restore procedures.

֍ 0.66
- Fixed issue that caused the restore script to terminate prematurely when
  deleting files before copying over the backup.

֍ 0.666
- Realized I had backep up incomplete settings due to the premature termination
  issue that were then restored while testing and I might have lost dozens of
  G Hub profiles created over years.
- Remembered I had deleted the backup-backup "because I don't need it anymore
  to prevent data loss while testing, the scripts are working fine."
- Panicked.
- Regreted having ever have progressed from version 0.2.
- Why the fuck did I have to get cocky and decide to facilitate sharing this?
  What do you want, validation and praise from strangers on the interwebs for
  how awesome you are for helping them circumvent G Hub's limitations? Fuck me
  sideways with Negan's baseball bat! You're so fucking inscure and needy! All
  was fine, you had to go and break it. That's terrible data safety practice,
  what are you, Facebook?
- Fuck fuck fuck!
- Downloaded file recovery software in a desperate and knowingly vain attempt
  at restoring lost backup files, which only found a single sub-directory with
  mostly damaged files.
- Sent frantic audio messages to a friend trying to make sense of the shit I
  had dug myself into and share the burden to prevent an axiety attack.
- Remembered while recording the second audio message there was a slight
  possibility who knows I might possibly still have an older backup but I think
  I deleted it and confirmed that, yep, it's gone.
- Found an even older backup of over six months by pure chance saved on the
  secondary drive for redundancy that I didn't remember of while opening an
  unrelated location, so only a few recently added profiles would be lost.
- Restored said backup, G Hub threw a hissy fit whenever launched and restarted
  itself repeatedly.
- Terminated lghub_updater.exe in Task Manager, relaunched G Hub, all my
  settings were there smiling at me with open arms, even those from less than a
  month ago, for some reason I can't quite explain to this day.
- Nature is healing.

֍ 0.67
- Added check to confirm all four backup directories are present in the backup.
- Saved a backup-backup because fool me twice, you... you can't fool me again.

֍ 0.675
- Code optimized
- Visual presentation improvements
- Tweaked pause between steps
- Changed batch file names to not use the same name as the backup directory.
- Changed backup directory and batch files names to not use spaces.

֍ 0.68
- Overhauled the process termination routine to first check whether processes
  are running before terminating them.

֍ 0.685
- Added additional commands to terminate the lghub_agent.exe process multiple
  times as it restarts a few seconds after being terminated in more recent
  G Hub versions.
- Added /F to the command to terminate lghub.exe that was missing and caused
  lghub_agent.exe to restart after an even shorter time.
- Removed note in the processes termination step about an error that would be
  shown when terminating processes if G Hub isn't running as that was fixed by
  first checking if processes are running.
- Modified the routine for the process termination banner to only show the
  information if any of the processes is running.

֍ 0.69
- Nice.
- Modified the routine for the process termination banner to show the
  information only before the first process is terminated and not again in
  subsequent ones.
- Added lghub_system_tray.exe to the list of processes to be terminated.

֍ 0.7
* Hello world.

֍ 0.8
* Joined the backup and restore scripts into a single batch file.

֍ 0.9
* Added option to choose custom locations to save and restore the backup.
* Renamed the batch file to reflect the name of the utility and show version
* Updated the information prompts and fixed some details. The freaking / and \
  mess me up every time.
