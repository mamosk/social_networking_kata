@ECHO OFF

WHERE docker >nul 2>&1
IF %ERRORLEVEL% NEQ 0 ECHO Error: docker is not installed. Get it at bit.ly/getdockerce >&2 && EXIT 1

WHERE docker-compose >nul 2>&1
IF %ERRORLEVEL% NEQ 0 ECHO Error: docker-compose is not installed. Get it at bit.ly/getdockercompose >&2 && EXIT 1

PUSHD %~dp0
  TYPE ascii\intro.art
  TIMEOUT 3 >nul
  docker-compose up -d --build --force-recreate
  docker-compose ps
  docker-compose exec cli /kata/cli.sh %*
  docker-compose down -v --rmi all
  TYPE ascii\outro.art
POPD
