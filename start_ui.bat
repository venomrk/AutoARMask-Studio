@echo off
title AutoARMask Studio - UI
echo ================================================
echo   AutoARMask Studio - Flutter Desktop App
echo ================================================
echo.
cd /d "%~dp0flutter_app"
echo Starting Flutter UI...
echo.
flutter run -d windows
pause
