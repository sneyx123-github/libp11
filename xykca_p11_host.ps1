# TODO: Import-Module
. $dp\yxenv.ps1

Save-Env
Prepend-Env -Paths @('C:\msys64\usr\bin', 'C:\Program Files\Yubico\Yubico PIV Tool\bin', 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64')
C:\msys64\usr\bin\bash.exe
