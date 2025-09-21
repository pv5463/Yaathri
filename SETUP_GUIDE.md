# 🚀 TravelSync - Complete Setup Guide

## 📋 Prerequisites

Before starting, ensure you have the following installed:

- **Flutter SDK 3.10+** - [Download here](https://flutter.dev/docs/get-started/install)
- **Node.js 18+** - [Download here](https://nodejs.org/)
- **Git** - [Download here](https://git-scm.com/)
- **VS Code** (recommended) - [Download here](https://code.visualstudio.com/)

## 🔧 Quick Setup (Automated)

### Option 1: Run the deployment script
```bash
# Navigate to the project root
cd C:\Users\hp\Desktop\SIH

# Run the automated setup
deploy.bat
```

### Option 2: Manual Setup

## 🖥️ Backend API Setup

1. **Navigate to backend directory:**
```bash
cd travel_sync_backend
```

2. **Install dependencies:**
```bash
npm install
```

3. **Environment Configuration:**
   - The `.env` file is already configured with your Supabase and Cloudinary credentials
   - Verify the configuration in `.env` file

4. **Run database migrations:**
```bash
npm run migrate
```

5. **Start the backend server:**
```bash
npm run dev
# OR use the startup script
start.bat
```

The backend will be available at: `http://localhost:5000`

### 🔍 Backend Verification
- Health Check: `http://localhost:5000/health`
- API Documentation: `http://localhost:5000/api-docs`

## 📱 Flutter Mobile App Setup

1. **Navigate to Flutter app directory:**
```bash
cd travel_sync_app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Generate code (if needed):**
```bash
flutter packages pub run build_runner build
```

4. **Run the app:**
```bash
flutter run
```

### 📱 Device Selection
When running `flutter run`, you'll see available devices:
- **Windows (desktop)** - For desktop testing
- **Chrome (web)** - For web testing
- **Connected Android/iOS device** - For mobile testing

## 🎛️ Admin Dashboard Setup

1. **Navigate to admin dashboard directory:**
```bash
cd natpac_admin_dashboard
```

2. **Install dependencies:**
```bash
npm install
```

3. **Start the development server:**
```bash
npm run dev
```

The admin dashboard will be available at: `http://localhost:3000`

## 🔗 Service Integration

### Database (Supabase PostgreSQL)
✅ **Already Configured**
- Host: `aws-1-ap-southeast-1.pooler.supabase.com`
- Database: `postgres`
- Connection pooling optimized for Supabase

### Media Storage (Cloudinary)
✅ **Already Configured**
- Cloud Name: `dsowqiw1n`
- API Key: `459754623547978`
- Upload preset: `travel_sync_preset`

## 🚀 Running All Services

### Terminal 1 - Backend API
```bash
cd travel_sync_backend
npm run dev
```

### Terminal 2 - Flutter App
```bash
cd travel_sync_app
flutter run
```

### Terminal 3 - Admin Dashboard
```bash
cd natpac_admin_dashboard
npm run dev
```

## 📊 Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Backend API | `http://localhost:5000` | REST API & WebSocket |
| API Docs | `http://localhost:5000/api-docs` | Swagger Documentation |
| Flutter App | Device/Emulator | Mobile Application |
| Admin Dashboard | `http://localhost:3000` | Research Dashboard |

## 🔧 Configuration Details

### Backend Environment Variables
The `.env` file contains:
- ✅ Supabase PostgreSQL connection
- ✅ Cloudinary API credentials
- ✅ JWT secrets (update for production)
- ✅ Pool configuration optimized for Supabase

### Flutter Configuration
- ✅ API endpoint configured for localhost
- ✅ Cloudinary credentials integrated
- ✅ Offline-first architecture with Hive
- ✅ Clean architecture with BLoC pattern

### Admin Dashboard Configuration
- ✅ Next.js with TypeScript
- ✅ Tailwind CSS for styling
- ✅ Recharts for data visualization
- ✅ Leaflet maps for location data

## 🧪 Testing the Setup

### 1. Backend API Test
```bash
curl http://localhost:5000/health
```
Expected response:
```json
{
  "success": true,
  "message": "TravelSync API is running",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "version": "1.0.0"
}
```

### 2. Database Connection Test
Check the backend console for:
```
Database connected successfully
```

### 3. Flutter App Test
- App should launch without errors
- Authentication screens should be visible
- Navigation should work smoothly

### 4. Admin Dashboard Test
- Dashboard should load at `http://localhost:3000`
- Charts and maps should render
- Mock data should be displayed

## 🔐 Security Notes

### For Development:
- ✅ Database credentials are configured
- ✅ Cloudinary credentials are set
- ⚠️ JWT secrets should be changed for production
- ⚠️ CORS is configured for localhost

### For Production:
- [ ] Update JWT secrets
- [ ] Configure proper CORS origins
- [ ] Set up SSL certificates
- [ ] Configure production database
- [ ] Set up monitoring and logging

## 📱 Mobile App Features

### ✅ Implemented Features:
- Multi-provider authentication (Email, Phone, Google, Apple, Facebook)
- Real-time GPS tracking with automatic trip detection
- Trip planning and itinerary management
- Expense tracking with bill splitting
- Offline-first capabilities with local storage
- Cloudinary integration for media storage
- Premium UI/UX with animations

### 🎯 Key Screens:
- Authentication flow (Login, Register, OTP)
- Home dashboard with quick actions
- Trip tracking and history
- Expense management
- Trip planning and itinerary
- Profile and settings

## 🎛️ Admin Dashboard Features

### ✅ Implemented Features:
- Real-time data visualization with interactive charts
- Interactive maps showing travel patterns
- User management and analytics
- Data export capabilities (CSV/Excel)
- Responsive design with modern UI

### 📊 Key Sections:
- Dashboard overview with statistics
- Travel analytics and patterns
- User behavior insights
- Data export tools
- System monitoring

## 🐛 Troubleshooting

### Common Issues:

#### Backend won't start:
```bash
# Check if port 5000 is available
netstat -an | findstr :5000

# If port is busy, change PORT in .env file
```

#### Database connection fails:
- Verify Supabase credentials in `.env`
- Check internet connection
- Ensure Supabase project is active

#### Flutter build errors:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### Admin dashboard won't start:
```bash
# Clear npm cache and reinstall
npm cache clean --force
rm -rf node_modules
npm install
```

## 📞 Support

If you encounter any issues:
1. Check the console logs for error messages
2. Verify all environment variables are set correctly
3. Ensure all services are running on their respective ports
4. Check network connectivity for external services

## 🎉 Success Indicators

✅ **Backend API**: Health endpoint returns success
✅ **Database**: Migrations run successfully
✅ **Flutter App**: Launches without errors
✅ **Admin Dashboard**: Loads with mock data
✅ **Integration**: All services communicate properly

---

**🚀 Your TravelSync application is now ready for development and testing!**
