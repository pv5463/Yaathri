@echo off
echo ========================================
echo NATPAC Admin Dashboard Setup
echo ========================================
echo.

echo Installing dependencies...
call npm install

echo.
echo Setting up environment file...
if not exist .env.local (
    echo NEXT_PUBLIC_API_URL=http://localhost:5000/api > .env.local
    echo NEXT_PUBLIC_APP_NAME=NATPAC Admin Dashboard >> .env.local
    echo Environment file created successfully!
) else (
    echo Environment file already exists.
)

echo.
echo Building the application...
call npm run build

echo.
echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
echo To start the development server, run:
echo npm run dev
echo.
echo To start the production server, run:
echo npm start
echo.
echo The dashboard will be available at:
echo http://localhost:3000
echo ========================================
pause
