@echo off

rem <> Manually set path to JLink install directory here if you do not
rem    want to use the auto detect method. Make sure a backslash
rem    is at the end of the path
set BASE=C:\Program Files (x86)\SEGGER\JLink_V500k\
if exist "%BASE%\JLink.exe" goto PATH_SET

rem <> Try to automatically detect JLink install directory
set KEYNAME=HKCU\Software\SEGGER\J-Link
set VALNAME=InstallPath
rem Check if JLink is installed first
reg query %KEYNAME% /v %VALNAME%
if not "%ERRORLEVEL%" == "0" (goto NO_PATH)
rem Query the value and then pipe it through findstr in order to find the matching line that has the value.
rem Only grab token 3 and the remainder of the line. %%b is what we are interested in here.
for /f "tokens=2,*" %%a in ('reg query %KEYNAME% /v %VALNAME% ^| findstr %VALNAME%') do (
    set BASE=%%b
)
if exist "%BASE%\JLink.exe" goto PATH_SET

:NO_PATH
chgclr 0C
echo ===================================================================
echo ERROR: You need to set the path for JLink.exe 
echo ===================================================================
pause
chgclr 07
exit
:PATH_SET

rem <> extract the version number from the path
set MINJVER=V500j
set JVER=%BASE:~-6%
set JVER=%JVER:~0,-1%
rem Remove '_' if present
set JVER=%JVER:_V=V%
echo Your JLINK Version is %JVER%
echo Minimum JLINK Version is %MINJVER%
echo.
if /I %JVER% GEQ %MINJVER% (goto JTAGCONF_CHECK)
chgclr 0C
echo ===================================================================
echo ERROR: You need at least JLINK verison %MINJVER%
echo ===================================================================
pause
chgclr 07
exit

:JTAGCONF_CHECK
rem <> After version 5.10, a new command line option is needed
set JTAGCONFVER=V510
set JTAGCONF=
if /I %JVER% GEQ %JTAGCONFVER% (set JTAGCONF=-jtagconf -1,-1)

echo.
:OPTIONS
chgclr 1F & echo.                    OPTIONS                      
chgclr 0A
echo 1 = Program u-boot
echo 2 = Program Device Tree Blob
echo 3 = Program Kernel (uImage)
echo 4 = Program Kernel (xipImage)
echo 5 = Program Rootfs (squashfs)
echo 6 = Program Rootfs (axfs)
echo 9 = Exit
chgclr 0F
SET /P REPLY=Choose option: 
chgclr 07
if "%REPLY%"== "1" (goto PROGRAM)
if "%REPLY%"== "2" (goto PROGRAM)
if "%REPLY%"== "3" (goto PROGRAM)
if "%REPLY%"== "4" (goto PROGRAM)
if "%REPLY%"== "5" (goto PROGRAM)
if "%REPLY%"== "6" (goto PROGRAM)
if "%REPLY%"== "9" (goto END)
chgclr 0C
echo ERROR: Please select from the list only.
echo.
goto OPTIONS

:PROGRAM
chgclr 0B
echo.
echo.
echo Set SW6 as instructed below:
echo SW6-1 OFF, SW6-2 ON, SW6-3 OFF, SW6-4 ON, SW6-5 ON, SW6-6 ON
echo.
chgclr 0F
echo.      SW6
echo.ON
chgclr 47
echo +-------------+
echo ^|   -   - - - ^|
echo ^| -   -       ^|
echo +-------------+
chgclr 07
echo   1 2 3 4 5 6 
echo.

chgclr 0B
echo.
pause

chgclr 0D
if "%REPLY%"== "1" GOTO UBOOT
if "%REPLY%"== "2" GOTO DTB
if "%REPLY%"== "3" GOTO KERNEL_UIMAGE
if "%REPLY%"== "4" GOTO KERNEL_XIP
if "%REPLY%"== "5" GOTO ROOTFS_SQUASHFS
if "%REPLY%"== "6" GOTO ROOTFS_AXFS
GOTO PROG_DONE

@REM =====u-boot========
:UBOOT
"%BASE%\JLink.exe" -speed 15000 -if JTAG %JTAGCONF% -device R7S721001 -CommanderScript load_spi_uboot.txt
GOTO PROG_DONE

@REM =====Device Tree Blob========
:DTB
"%BASE%\JLink.exe" -speed 15000 -if JTAG %JTAGCONF% -device R7S721001 -CommanderScript load_spi_dtb.txt
GOTO PROG_DONE

@REM =====Kernel (uImage)========
:KERNEL_UIMAGE
"%BASE%\JLink.exe" -speed 15000 -if JTAG %JTAGCONF% -device R7S721001_DualSPI -CommanderScript load_spi_kernel_uImage.txt
GOTO PROG_DONE

@REM =====Kernel (xipImage)========
:KERNEL_XIP
"%BASE%\JLink.exe" -speed 15000 -if JTAG %JTAGCONF% -device R7S721001_DualSPI -CommanderScript load_spi_kernel_xipImage.txt
GOTO PROG_DONE

@REM =====Rootfs (squashfs)========
:ROOTFS_SQUASHFS
"%BASE%\JLink.exe" -speed 15000 -if JTAG %JTAGCONF% -device R7S721001_DualSPI -CommanderScript load_spi_rootfs_squashfs.txt
GOTO PROG_DONE

@REM =====Rootfs (axfs)========
:ROOTFS_AXFS
"%BASE%\JLink.exe" -speed 15000 -if JTAG %JTAGCONF% -device R7S721001_DualSPI -CommanderScript load_spi_rootfs_axfs.txt
GOTO PROG_DONE

:PROG_DONE

chgclr 2F
echo.
echo.                                            
echo.                 Complete                   
echo.                                            
echo.
echo.
echo.
@REM Return back to main menu. You should option 9 to exit
chgclr 0E
echo.
echo.
GOTO OPTIONS


:END
chgclr 4F
echo.
echo.
echo.                                            
echo.       Power Cycle The Board                
echo.                                            
echo.
chgclr 0B
echo.      When you are done programming, you have to remove power from the
echo.      board for 5 seconds in order to be able to boot from QSPI again.
echo.
pause
chgclr 07
