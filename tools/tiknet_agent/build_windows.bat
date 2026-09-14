@echo off
echo ==========================================================
echo    Building Tiknet Router Provisioning Agent for Windows
echo ==========================================================

if not exist build mkdir build

echo Compiling native Windows executable with Dart...
dart compile exe bin\tiknet_agent.dart -o build\TiknetAgent.exe
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed.
    exit /b %ERRORLEVEL%
)

echo.
echo [SUCCESS] TiknetAgent.exe built successfully in build\TiknetAgent.exe
pause
