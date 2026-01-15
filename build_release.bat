@echo off
title AutoARMask Studio - Build
echo ================================================
echo   AutoARMask Studio - Building Release
echo ================================================
echo.
cd /d "%~dp0flutter_app"
echo Building Windows release...
flutter build windows --release
echo.
echo Build complete!
echo.
echo Output location: flutter_app\build\windows\x64\runner\Release\
explorer "%~dp0flutter_app\build\windows\x64\runner\Release"
pause
