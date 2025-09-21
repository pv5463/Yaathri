@echo off
echo Starting TravelSync Backend API...
echo.
echo Checking environment variables...
if not exist .env (
    echo ERROR: .env file not found!
    echo Please ensure .env file exists with database and API credentials.
    pause
    exit /b 1
)

echo Environment file found ✓
echo.
echo Starting server on port 5000...
echo API Documentation will be available at: http://localhost:5000/api-docs
echo Health check endpoint: http://localhost:5000/health
echo.

npm run dev
