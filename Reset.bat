:init
@echo off
color 4f
cls
cd /d %~dp0
net session >nul 2>&1
if %errorLevel% == 0 (
goto vars
) else (
goto runasadmin
)


rem Starts the program with initial settings and checks if the program is being run as admin


:vars
cls
echo Getting system information...
if %PROCESSOR_ARCHITECTURE% == AMD64 (
set archtype=64 Bit
goto confirm)
if %PROCESSOR_ARCHITECTURE% == x86 (
set archtype=32 Bit
goto confirm) else (goto unsupported)


rem Checks the processor's archetecture and sets a varible based upon what is found. If there is an unkown arthecture then it goes to the unsupported section.


:confirm
cls
echo Are you sure that you want to reset Syncthing?
echo This will cause a disruprion on *this* computer's syncing!
echo ONLY do this if you are having trouble with Syncthing!!!
echo.
choice /c RC /m "Press \"R\" to Reset or press \"C\" to Cancel... "
if %errorlevel%==1 (
goto doubbleconfirm
) else (goto exit)


rem Checks if the user wants to reset syncthing


:doubbleconfirm
cls
echo Are you absolutely sure that you want to reset syncthing?
echo This is your last chance to back out!
echo.
choice /c EC /m "Press \"E\" to Exit or press \"C\" to Confirm... "
if %errorlevel%==2 (goto check
) else (goto exit)


rem Doubble checks if the user wants to reset syncthing


:check
cls
if not exist C:\syncthingtemp\ mkdir C:\syncthingtemp\
if exist C:\syncthingtemp\syncthing-windows*.zip goto stop
echo Please download and place the %archtype% Windows version ZIP file
echo of Syncthing in this folder.
pause
cls
echo Place the %archtype% zip file in the file browser that was opened
echo then press any key to continue.
echo.
start https://syncthing.net/
start C:\syncthingtemp\
pause
if not exist C:\syncthingtemp\extracted\ mkdir C:\syncthingtemp\extracted\
goto check


rem Checks if the zip file of syncthing is available for usage.
rem If the zip file is not found then it prompts the user download it and place it in a specific folder.
rem The folder is autocreated if it does not exist.


:stop
cls
echo Stoping running instances of Syncthing...
taskkill /IM syncthing.*
goto clear


rem Closes all instances of Syncthing so that files can be edited.


:clear
cls
echo Cleaning out Syncthing directory for new files...
rmdir /S /Q C:\syncthing
mkdir C:\Syncthing
goto preunpack


rem Removes the syncthing folder so that the new syncthing files can be installed


:preunpack
cls
echo Unpacking and moving files into position...
setlocal
for %%a in ("C:\syncthingtemp\*.zip") do call:UnpackMove "%%a"
endlocal
goto schvars


rem Sends the commands to unpack the users zip file.


:UnpackMove
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem';[IO.Compression.ZipFile]::ExtractToDirectory('C:\syncthingtemp\%~nx1', 'C:\syncthingtemp\extracted\'); }"
xcopy /E "C:\syncthingtemp\extracted\%~n1" C:\Syncthing\
exit /b


rem Unzips the specified zip file into a specific folder.
rem Moves the files into position.


:icon
cls
echo Creating settings icon...
if exists "Syncthing Settings.lnk" del "%cd%\Syncthing Settings.lnk"
(
echo([{000214A0-0000-0000-C000-000000000046}]
echo(Prop3=19,2
echo([InternetShortcut]
echo(IDList=
echo(URL=http://127.0.0.1:8384/
)>"Syncthing Settings.lnk"
goto schvars


rem Deletes existing icon if present in current directory and creates a new settings icon.
rem Currently does not work so it is excluded from the execution flow.


:schvars
cls
echo Creating/resetting scheduled task...
schtasks /Delete /TN Syncthing /F
set year=%date:~10,4%
set month=%date:~4,2%
set day=%date:~7,2%
set scripttime=%time:~0,8%
for /f "delims= " %%a in ('"wmic useraccount where name='%username%' get sid"') do (
if not "%%a"=="SID" (set usersid=%%a
goto :createxml))


rem Gets varables for XML files and deletes existing scheduled task.


:createxml
(
echo(^<?xml version^="1.0" encoding^="UTF-16"?^>
echo(^<Task version^="1.2" xmlns^="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo(  ^<RegistrationInfo^>
echo(    ^<Date^>%year%-%month%-%day%T%scripttime%.1008091^</Date^>
echo(    ^<Author^>%computername%\%username%^</Author^>
echo(    ^<Description^>Syncthing autostart task^</Description^>
echo(    ^<URI^>\Syncthing^</URI^>
echo(  ^</RegistrationInfo^>
echo(  ^<Triggers^>
echo(    ^<LogonTrigger^>
echo(      ^<Enabled^>true^</Enabled^>
echo(    ^</LogonTrigger^>
echo(  ^</Triggers^>
echo(  ^<Principals^>
echo(    ^<Principal id^="Author"^>
echo(      ^<UserId^>%usersid%^</UserId^>
echo(      ^<LogonType^>InteractiveToken^</LogonType^>
echo(      ^<RunLevel^>LeastPrivilege^</RunLevel^>
echo(    ^</Principal^>
echo(  ^</Principals^>
echo(  ^<Settings^>
echo(    ^<MultipleInstancesPolicy^>IgnoreNew^</MultipleInstancesPolicy^>
echo(    ^<DisallowStartIfOnBatteries^>false^</DisallowStartIfOnBatteries^>
echo(    ^<StopIfGoingOnBatteries^>true^</StopIfGoingOnBatteries^>
echo(    ^<AllowHardTerminate^>false^</AllowHardTerminate^>
echo(    ^<StartWhenAvailable^>false^</StartWhenAvailable^>
echo(    ^<RunOnlyIfNetworkAvailable^>false^</RunOnlyIfNetworkAvailable^>
echo(    ^<IdleSettings^>
echo(      ^<StopOnIdleEnd^>true^</StopOnIdleEnd^>
echo(      ^<RestartOnIdle^>false^</RestartOnIdle^>
echo(    ^</IdleSettings^>
echo(    ^<AllowStartOnDemand^>true^</AllowStartOnDemand^>
echo(    ^<Enabled^>true^</Enabled^>
echo(    ^<Hidden^>false^</Hidden^>
echo(    ^<RunOnlyIfIdle^>false^</RunOnlyIfIdle^>
echo(    ^<WakeToRun^>false^</WakeToRun^>
echo(    ^<ExecutionTimeLimit^>PT0S^</ExecutionTimeLimit^>
echo(    ^<Priority^>7^</Priority^>
echo(  ^</Settings^>
echo(  ^<Actions Context^="Author"^>
echo(    ^<Exec^>
echo(      ^<Command^>C:\Syncthing\Syncthing.exe^</Command^>
echo(      ^<Arguments^>-no-console -no-browser^</Arguments^>
echo(    ^</Exec^>
echo(  ^</Actions^>
echo(^</Task^>
)>"C:\syncthingtemp\schtsk.xml"
goto createschtsk


rem creates xml file with customized settings for current user


:createschtsk
schtasks /create /TN Syncthing /xml "C:\syncthingtemp\schtsk.xml"
goto startprocess


rem Creates a new scheduled task for Syncthing auto start


:startprocess
cls
echo Starting Syncthing...
schtasks /run /tn Syncthing
goto cleanup


rem Starts the syncthing program in the background.


:cleanup
cls
echo Cleaning up...
rmdir /S /Q C:\syncthingtemp\
goto message


rem Sleans up after the extraction and file manipulation.


:message
cls
echo The utility has completed, your sync services
echo should be restored.
pause
goto exit


rem Tells the user that the program has completed.


:unsupported
cls
echo Unfortuneately only Windows 32bit and 64bit x86 compatible versions are
echo supported.
pause
goto exit


rem Tells teh user that Syncthing is unsupported on their platform.


:runasadmin
cls
echo This script needs to be run as admin.
echo.
echo To do this, right click on this script and select run as administrator.
pause
goto exit


rem Displays information to user on how to run this script as admin.


:exit
exit /B


rem Exits this script cleanly.