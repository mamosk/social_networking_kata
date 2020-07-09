@ECHO OFF

WHERE docker >nul 2>&1
IF %ERRORLEVEL% NEQ 0 ECHO Error: docker is not installed. >&2 && EXIT 1

WHERE docker-compose >nul 2>&1
IF %ERRORLEVEL% NEQ 0 ECHO Error: docker-compose is not installed. >&2 && EXIT 1

PUSHD %~dp0
  TYPE kata.art
  docker-compose up -d --build --force-recreate
POPD
