# 🔧 API Configuration Guide

This document explains how to configure the API endpoints for all components of the Yaathri travel data collection system.

## 🌐 Current Configuration

**Backend Deployment URL:** `https://yaathri.onrender.com`
**API Base URL:** `https://yaathri.onrender.com/api`

## 📱 Components Configuration

### 1. **Flutter Mobile App** (`travel_sync_app/`)

#### Primary Configuration Files:
- **`lib/core/config/app_config.dart`** - Main configuration
- **`lib/core/config/environment.dart`** - Environment-specific settings
- **`lib/core/network/api_client.dart`** - API client configuration

#### Current Settings:
```dart
// Production URL (Current)
static const String baseUrl = 'https://yaathri.onrender.com/api';

// Development URL (for local testing)
// static const String baseUrl = 'http://localhost:5000/api';
```

#### To Change API URL:
1. Open `lib/core/config/environment.dart`
2. Update the `Environment.production` case in the `baseUrl` getter
3. Or change `_currentEnvironment` to `Environment.development` for local testing

### 2. **Admin Dashboard** (`natpac_admin_dashboard/`)

#### Configuration Files:
- **`.env.local`** - Local environment variables
- **`.env.production`** - Production environment variables
- **`src/services/apiService.ts`** - API service configuration

#### Current Settings:
```bash
NEXT_PUBLIC_API_URL=https://yaathri.onrender.com/api
NEXT_PUBLIC_APP_NAME=NATPAC Admin Dashboard
NEXT_PUBLIC_ENVIRONMENT=production
```

#### To Change API URL:
1. Update `.env.local` or `.env.production`
2. Or modify the default URL in `src/services/apiService.ts`
3. Restart the development server: `npm run dev`

### 3. **Backend API** (`travel_sync_backend/`)

#### Configuration Files:
- **`.env`** - Environment variables
- **`.env.production`** - Production settings

#### Current Deployment:
- **Platform:** Render.com
- **URL:** https://yaathri.onrender.com
- **Database:** PostgreSQL (hosted)

## 🔄 Environment Switching

### For Development (Local Backend):
```bash
# Admin Dashboard (.env.local)
NEXT_PUBLIC_API_URL=http://localhost:5000/api

# Flutter App (environment.dart)
static const Environment _currentEnvironment = Environment.development;
```

### For Production (Deployed Backend):
```bash
# Admin Dashboard (.env.local)
NEXT_PUBLIC_API_URL=https://yaathri.onrender.com/api

# Flutter App (environment.dart)
static const Environment _currentEnvironment = Environment.production;
```

## 🚀 Quick Setup Scripts

### Admin Dashboard:
```bash
# For production deployment
./deploy.bat

# For development
./setup.bat
```

### Flutter App:
```bash
# No additional setup needed - configuration is in code
flutter clean
flutter pub get
flutter run
```

## 🔍 Verification Steps

### 1. **Check API Connectivity**
```bash
# Test if backend is accessible
curl https://yaathri.onrender.com/api/health

# Expected response: {"status": "ok", "timestamp": "..."}
```

### 2. **Admin Dashboard**
1. Open browser developer tools
2. Check Network tab for API calls
3. Verify requests are going to `https://yaathri.onrender.com/api`

### 3. **Flutter App**
1. Check app logs for API connection attempts
2. Verify authentication and data sync work properly
3. Test offline/online functionality

## 🛠️ Troubleshooting

### Common Issues:

#### **CORS Errors**
- Ensure backend has proper CORS configuration
- Check if the deployed backend allows requests from your domain

#### **Connection Timeouts**
- Render.com free tier may have cold starts (30+ seconds)
- First request after inactivity may be slow

#### **Authentication Issues**
- Verify JWT tokens are being sent correctly
- Check token expiration and refresh logic

#### **Environment Variables Not Loading**
```bash
# Admin Dashboard - restart development server
npm run dev

# Flutter App - clean and rebuild
flutter clean && flutter pub get && flutter run
```

## 📝 Configuration Checklist

- [ ] Backend deployed and accessible at `https://yaathri.onrender.com`
- [ ] Admin dashboard `.env.local` updated with correct API URL
- [ ] Flutter app `environment.dart` set to production
- [ ] CORS configured on backend for frontend domains
- [ ] Database connection working on deployed backend
- [ ] Authentication endpoints responding correctly
- [ ] File upload/download endpoints working
- [ ] Real-time features (WebSocket/SSE) configured

## 🔐 Security Notes

### Production Considerations:
- Use HTTPS for all API communications
- Implement proper authentication and authorization
- Set up rate limiting on the backend
- Configure proper CORS policies
- Use environment variables for sensitive data
- Enable request/response logging for debugging

### API Keys and Secrets:
- Never commit API keys to version control
- Use environment variables for all sensitive configuration
- Rotate keys regularly in production
- Implement proper key management

## 📞 Support

If you encounter issues with API configuration:

1. **Check Backend Status:** Visit https://yaathri.onrender.com/api/health
2. **Verify Environment Variables:** Ensure all required variables are set
3. **Check Network Connectivity:** Test API endpoints with curl or Postman
4. **Review Logs:** Check both frontend and backend logs for errors

---

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Backend URL:** https://yaathri.onrender.com/api
**Status:** ✅ Configured for Production
