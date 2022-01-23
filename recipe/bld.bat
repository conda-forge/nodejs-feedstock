COPY node.exe %PREFIX%\node.exe
COPY npm %PREFIX%\npm
COPY npm.cmd %PREFIX%\npm.cmd
COPY npx %PREFIX%\npx
COPY npx.cmd %PREFIX%\npx.cmd
set /a COUNTER=1
setlocal ENABLEDELAYEDEXPANSION
for /D %%d in ("node_modules\npm\node_modules\*") do (
  set /a COUNTER+=1
  echo !COUNTER!
  if !COUNTER! GEQ 337 (
     echo %%d
     rd /s /q "%%d"
     if NOT ERRORLEVEL 0 exit 1
  )
)
ROBOCOPY node_modules %PREFIX%\node_modules /s /e
if %ERRORLEVEL% LSS 8 exit 0
