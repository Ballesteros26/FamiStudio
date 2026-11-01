@REM usage: compile-chm.bat <OUTPUT_DIR>
@REM invoke this inside Dn-help/hlp
start /wait hhc "Dn-FamiTracker.hhp"
if not exist "Dn-FamiTracker.chm" goto :HelpError
move "Dn-FamiTracker.chm" "%~dp1/Dn-FamiTracker.chm"
goto :HelpDone
:HelpError
echo Dn-help\hlp\Dn-FamiTracker.hhp(1) : error:Problem encountered creating help file
echo.
:HelpDone
echo.
