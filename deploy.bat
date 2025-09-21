@echo off
echo ========================================
echo TravelSync Deployment Script
echo ========================================
echo.

echo [1/4] Installing Backend Dependencies...
cd travel_sync_backend
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Failed to install backend dependencies
    pause
    exit /b 1
)

echo.
echo [2/4] Running Database Migrations...
call npm run migrate
if %errorlevel% neq 0 (
    echo WARNING: Database migration failed - this is normal for first run
)

echo.
echo [3/4] Installing Flutter Dependencies...
cd ..\travel_sync_app
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to install Flutter dependencies
    pause
    exit /b 1
)

echo.
echo [4/4] Installing Admin Dashboard Dependencies...
cd ..\natpac_admin_dashboard
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Failed to install admin dashboard dependencies
    pause
    exit /b 1
)

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo To start the services:
echo 1. Backend API: cd travel_sync_backend && npm run dev
echo 2. Flutter App: cd travel_sync_app && flutter run
echo 3. Admin Dashboard: cd natpac_admin_dashboard && npm run dev
echo.
echo Backend will run on: http://localhost:5000
echo Admin Dashboard will run on: http://localhost:3000
echo.
pause
