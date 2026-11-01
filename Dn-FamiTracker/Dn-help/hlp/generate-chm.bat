@rem generates an HTMLHelp .chm file
@rem requires the superproject Dn-FamiTracker.
@rem invoke inside Dn-help/hlp
setlocal 
@call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsamd64_x86.bat" x86_amd64
cd ..\..\
call generate-helpmap.bat
cd %~dp0
call update-htm-templates.bat %~dp0
call compile-chm.bat