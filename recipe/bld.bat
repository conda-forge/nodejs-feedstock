if "%ARCH%"=="32" (
   set PLATFORM=x86
) else (
  set PLATFORM=x64
)
:: Remove -GL from CXXFLAGS as whole program optimization takes too much time and memory
set "CFLAGS= -MD"
set "CXXFLAGS= -MD"

call vcbuild.bat nosign nosnapshot no-cctest release %PLATFORM%

COPY Release\node.exe %PREFIX%\node.exe

%PREFIX%\node.exe -v
%PREFIX%\node.exe deps\npm\bin\npm-cli.js install deps\npm -gf
cmd /c %PREFIX%\npm.cmd version
REM dedupe npm to avoid too-long path issues on Windows
cd %PREFIX%\node_modules\npm
cmd /c %PREFIX%\npm.cmd dedupe
