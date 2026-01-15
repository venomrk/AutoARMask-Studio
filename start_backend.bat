@echo off
title AutoARMask Studio - Backend
echo ================================================
echo   AutoARMask Studio - Python Backend Server
echo ================================================
echo.
cd /d "%~dp0backend"
echo Starting backend server...
echo.
python main.py
pause
