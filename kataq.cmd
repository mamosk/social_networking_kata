@ECHO OFF

WHERE bash >nul 2>&1
IF %ERRORLEVEL% NEQ 0 ECHO Error: bash is not installed. Get it at bit.ly/getwinbash >&2 && EXIT 1

PUSHD %~dp0
  bash -c "export MODE=mono && frontend/bash/katacli.sh %*"
POPD
