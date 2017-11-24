if "%ARCH%"=="32" (
   set PLATFORM=x86
) else (
  set PLATFORM=x64
)

call vcbuild.bat nosign release %PLATFORM%

COPY Release\node.exe %LIBRARY_BIN%\node.exe

%LIBRARY_BIN%\node.exe -v
%LIBRARY_BIN%\node.exe deps\npm\bin\npm-cli.js install npm -gf
REM dedupe to avoid too-long path issues on Windows
%LIBRARY_BIN%\npm.cmd dedupe
%LIBRARY_BIN%\npm.cmd version
