COPY node.exe %PREFIX%\node.exe
COPY npm %PREFIX%\npm
COPY npm.cmd %PREFIX%\npm.cmd
COPY npx %PREFIX%\npx
COPY npx.cmd %PREFIX%\npx.cmd
rd /s /q "node_modules\npm\node_modules\node-gyp"
if NOT ERRORLEVEL 0 exit /b 1
rd /s /q "node_modules\npm\node_modules\har-validator"
if NOT ERRORLEVEL 0 exit /b 1
rd /s /q "node_modules\npm\node_modules\bluebird"
if NOT ERRORLEVEL 0 exit /b 1
ROBOCOPY node_modules %PREFIX%\node_modules /s /e
if %ERRORLEVEL% LSS 8 exit 0
