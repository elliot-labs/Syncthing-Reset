:start
@echo off
color 4f
cls
cd /d %~dp0
goto vars


:vars
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
echo This will cause a disruprion on *this* computer's network syncing!
echo ONLY do this if you are having an issue with syncthing!!!
echo.
choice /c RC /m "Press \"R\" to Reset or press \"C\" to Cancle..."
if %errorlevel%==1 (
goto doubbleconfirm
) else (goto exit)


rem Checks if the user wants to reset syncthing


:doubbleconfirm
cls
echo Are you absolutely sure that you want to reset syncthing?
echo This is your last chance to back out!
echo.
choice /c RC /m "Press \"C\" to Confirm or press \"E\" to Exit..."
if %errorlevel%==2 (goto check
) else (goto exit)


rem Doubble checks if the user wants to reset syncthing


:check
cls
if not exist C:\syncthingtemp\ mkdir C:\syncthingtemp\extracted\
if not exist C:\syncthingtemp\extracted\ mkdir C:\syncthingtemp\extracted\
if exist C:\syncthingtemp\syncthing-windows*.zip goto stop
echo Please download and place the %archtype% Windows version ZIP file
echo of Syncthing in this folder.
pause
start C:\syncthingtemp\
start https://syncthing.net/
pause
goto check


rem Checks if the zip file of syncthing is available for usage.
rem If the zip file is not found then it prompts the user download it and place it in a specific folder.
rem The folder is autocreated if it does not exist.


:stop
taskkill /IM syncthing.*
goto clear


rem Closes all instances of Syncthing so that files can be edited.


:clear
rmdir /S /Q C:\syncthing
mkdir C:\Syncthing
goto preunpack


rem Removes the syncthing folder so that the new syncthing files can be installed


:preunpack
setlocal
for %%a in ("%cd%\*.zip") do call:UnpackMove "%%a"
endlocal
goto startprocess


rem sends the commands to unpack the users zip file.


:UnpackMove
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('C:\syncthingtemp\%~nx1', 'C:\syncthingtemp\extracted\'); }"
xcopy C:\syncthingtemp\extracted\%~n1 C:\Syncthing\


rem unzips the specified zip file into a specific folder.
rem Moves the files into position.


:startprocess
start C:\syncthing\syncthing.exe -no-console -no-browser
goto cleanup


rem starts the syncthing program in the background.


:cleanup
rmdir /S /Q C:\syncthingtemp\
goto message


rem cleans up after the extraction and file manipulation.


:message
cls
echo The utility has completed, your sync services
echo should be restored.
pause
goto exit


rem Tells the user that the program has completed.


:unsupported
cls
echo Unfortuneately only Windows 32bit and 64bit x86 compatible version are
echo supported.
pause
goto exit


rem Tells teh user that Syncthing is unsupported on their platform.


:exit
exit /B


rem Exits this script cleanly.
