COPY node.exe %PREFIX%\node.exe
COPY npm %PREFIX%\npm
COPY npm.cmd %PREFIX%\npm.cmd
COPY npx %PREFIX%\npx
COPY npx.cmd %PREFIX%\npx.cmd
rd /s /q "node_modules/npm/node_modules/term-size/vendor/macos"
if NOT ERRORLEVEL 0 exit 1
@rem set /a COUNTER=1
@rem setlocal ENABLEDELAYEDEXPANSION
@rem for /D %%d in ("node_modules\npm\node_modules\*") do (
@rem   set /a COUNTER+=1
@rem   echo !COUNTER!
@rem   if !COUNTER! LEQ 315 (
@rem      if !COUNTER! GEQ 315 (
@rem        echo %%d
@rem        rd /s /q "%%d"
@rem        if NOT ERRORLEVEL 0 exit 1
@rem      )
@rem   )
@rem )
ROBOCOPY node_modules %PREFIX%\node_modules /s /e
if %ERRORLEVEL% LSS 8 exit 0
