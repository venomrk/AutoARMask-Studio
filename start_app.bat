@echo off
title AutoARMask Studio - Full Application
echo ================================================
echo   AutoARMask Studio - Complete Application
echo ================================================
echo.
echo Step 1: Starting Python Backend Server...
start "AutoARMask Backend" cmd /k "cd /d "%~dp0backend" && python main.py"
echo Backend started.
echo.
echo Waiting 3 seconds for backend to initialize...
timeout /t 3 /nobreak > nul
echo.
echo Step 2: Starting Flutter Web UI...
cd /d "%~dp0flutter_app"
flutter run -d chrome
pause
