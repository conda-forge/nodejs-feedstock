COPY node.exe %PREFIX%\node.exe
COPY npm %PREFIX%\npm
COPY npm.cmd %PREFIX%\npm.cmd
COPY npx %PREFIX%\npx
COPY npx.cmd %PREFIX%\npx.cmd
ROBOCOPY node_modules %PREFIX%\node_modules /s /e
if %ERRORLEVEL% LSS 8 exit 0
