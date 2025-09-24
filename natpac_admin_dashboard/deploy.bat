@echo off
echo ========================================
echo NATPAC Admin Dashboard Deployment
echo ========================================
echo.

echo Current API URL: https://yaathri.onrender.com/api
echo.

echo Installing dependencies...
call npm install

echo.
echo Setting up production environment...
if exist .env.local (
    echo Backing up existing .env.local to .env.local.backup
    copy .env.local .env.local.backup
)

echo NEXT_PUBLIC_API_URL=https://yaathri.onrender.com/api > .env.local
echo NEXT_PUBLIC_APP_NAME=NATPAC Admin Dashboard >> .env.local
echo NEXT_PUBLIC_ENVIRONMENT=production >> .env.local

echo.
echo Building for production...
call npm run build

echo.
echo ========================================
echo Deployment build completed successfully!
echo ========================================
echo.
echo The application is now ready for deployment.
echo.
echo To start the production server locally:
echo npm start
echo.
echo To deploy to a hosting service:
echo 1. Upload the .next folder and other necessary files
echo 2. Set environment variables on your hosting platform
echo 3. Run 'npm start' on the server
echo.
echo API Configuration:
echo - Backend URL: https://yaathri.onrender.com/api
echo - Make sure your backend is running and accessible
echo ========================================
pause
