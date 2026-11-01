@REM invoke this inside Dn-help/hlp
@echo off
pandoc ..\..\CHANGELOG.md -f gfm -t html5 > temp.txt
python ..\htm-patcher.py changelog-template.htm changelog.htm temp.txt "PATCH HERE PLEASE"
del temp.txt
pandoc ..\..\LICENSE.md -f gfm -t html5 > temp.txt
python ..\htm-patcher.py license-template.htm license_temp.htm temp.txt "PATCH HERE FIRST"
del temp.txt
pandoc ..\..\Source\drivers\asm\LICENSE.md -f gfm -t html5 > temp.txt
python ..\htm-patcher.py license_temp.htm license.htm temp.txt "PATCH HERE SECOND"
del temp.txt
del license_temp.htm
