@echo on
COPY node.exe %PREFIX%\node.exe
if errorlevel 1 exit 1
COPY npm %PREFIX%\npm
if errorlevel 1 exit 1
COPY npm.cmd %PREFIX%\npm.cmd
if errorlevel 1 exit 1
COPY npx %PREFIX%\npx
if errorlevel 1 exit 1
COPY npx.cmd %PREFIX%\npx.cmd
if errorlevel 1 exit 1
ROBOCOPY node_modules %PREFIX%\node_modules /s /e
if %ERRORLEVEL% GEQ 8 exit 1
