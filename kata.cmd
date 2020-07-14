@ECHO OFF

WHERE docker >nul 2>&1
IF %ERRORLEVEL% NEQ 0 ECHO Error: docker is not installed. Get it at bit.ly/getdockerce >&2 && EXIT 1

WHERE docker-compose >nul 2>&1
IF %ERRORLEVEL% NEQ 0 ECHO Error: docker-compose is not installed. Get it at bit.ly/getdockercompose >&2 && EXIT 1

PUSHD %~dp0
  TYPE ascii\intro.art
  TIMEOUT 3 >nul
  PUSHD backend
    ECHO.
    ECHO "Building services, please wait..."
    TIMEOUT 1 >nul
    docker-compose up -d --build --force-recreate
    ECHO.
    ECHO "Initializing services, please wait..."
    TIMEOUT 3 >nul
    docker-compose ps
  POPD
  PUSHD frontend
    ECHO.
    ECHO "Building cli, please wait..."
    TIMEOUT 1 >nul
    docker-compose build
    ECHO.
    ECHO "Initializing cli, please wait..."
    docker-compose run --rm cli /kata/cli.sh %*
  POPD
  PUSHD backend
    docker-compose down
  POPD
  TYPE ascii\outro.art
POPD
