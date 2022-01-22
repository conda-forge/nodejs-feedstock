@rem COPY node.exe %PREFIX%\node.exe
@rem COPY npm %PREFIX%\npm
@rem COPY npm.cmd %PREFIX%\npm.cmd
@rem COPY npx %PREFIX%\npx
@rem COPY npx.cmd %PREFIX%\npx.cmd
ROBOCOPY node_modules %PREFIX%\node_modules /s /e
if %ERRORLEVEL% LSS 8 exit 0
