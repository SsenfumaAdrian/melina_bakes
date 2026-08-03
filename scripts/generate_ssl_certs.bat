@echo off
REM Melina Bakes — SSL Certificate Generator for Windows
REM Generates self-signed certificate for local development.
REM Requires: OpenSSL (bundled with Git for Windows: C:\Program Files\Git\usr\bin\openssl.exe)
setlocal

set "SSL_DIR=docker\nginx\ssl"

if not exist "%SSL_DIR%" mkdir "%SSL_DIR%"

echo.
echo === Melina Bakes — Self-Signed SSL for Local Development ===
echo Generating cert.pem and key.pem in %SSL_DIR% ...

openssl req -x509 -nodes -days 365 -newkey rsa:2048 ^
  -keyout "%SSL_DIR%\key.pem" ^
  -out "%SSL_DIR%\cert.pem" ^
  -subj "/CN=localhost"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: OpenSSL failed. Check that openssl.exe is on your PATH.
    echo       Install Git for Windows or download OpenSSL from https://slproweb.com/products/Win32OpenSSL.html
    exit /b 1
)

echo.
echo ==========================================
echo  Self-signed SSL certs created successfully
echo.
echo  Files:
echo    - %SSL_DIR%\cert.pem
echo    - %SSL_DIR%\key.pem
echo.
echo  NOTE: Self-signed certificate. Browsers show a security warning in dev.
echo ==========================================
pause