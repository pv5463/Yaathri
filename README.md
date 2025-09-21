# TravelSync - Travel Data Collection & Trip Planning App

A comprehensive cross-platform Flutter mobile application for travel data collection and trip planning, designed for NATPAC research with automatic GPS tracking, expense management, and offline-first capabilities.

## 🚀 Features

### Core Functionality
- **Automatic Trip Detection**: GPS-based trip start/stop detection
- **Manual Trip Entry**: User-friendly interface for manual trip logging
- **Multi-Modal Travel**: Support for walking, cycling, driving, public transport, flights, etc.
- **Real-time Location Tracking**: Background GPS tracking with route recording
- **Offline-First Architecture**: Works seamlessly without internet connection

### Trip Management
- **Digital Travel Journal**: Add photos, notes, and location stamps
- **Trip Planning & Itinerary**: Create detailed travel plans with dates and destinations
- **Group Travel**: Manage companions and shared trip experiences
- **Document Storage**: Secure storage for passports, tickets, visas via Cloudinary

### Expense Tracking
- **Smart Expense Categorization**: Automatic categorization of travel expenses
- **Budget Monitoring**: Set and track budgets with real-time alerts
- **Bill Splitting**: Split expenses among group travelers
- **Receipt Management**: Photo capture and storage of receipts

### Authentication & Security
- **Multi-Provider Auth**: Email, phone, Google, Apple, Facebook login
- **GDPR Compliance**: Comprehensive consent management
- **Data Encryption**: End-to-end encryption for sensitive data
- **Secure Document Storage**: Encrypted storage for travel documents

### Analytics & Insights
- **Travel Patterns**: Analyze travel behavior and patterns
- **Carbon Footprint**: Track environmental impact of trips
- **Expense Analytics**: Detailed spending analysis and trends
- **Research Data Export**: CSV/Excel export for NATPAC researchers

## 🏗️ Architecture

### Frontend (Flutter)
```
travel_sync_app/
├── lib/
│   ├── core/
│   │   ├── config/          # App configuration
│   │   ├── di/              # Dependency injection
│   │   ├── error/           # Error handling
│   │   ├── network/         # API client & network info
│   │   ├── router/          # Navigation routing
│   │   ├── services/        # Core services (location, background)
│   │   └── theme/           # App theming
│   ├── data/
│   │   ├── datasources/     # Local & remote data sources
│   │   ├── models/          # Data models
│   │   └── repositories/    # Repository implementations
│   ├── domain/
│   │   ├── entities/        # Business entities
│   │   ├── repositories/    # Repository interfaces
│   │   └── usecases/        # Business logic
│   └── presentation/
│       ├── blocs/           # State management (BLoC)
│       ├── screens/         # UI screens
│       └── widgets/         # Reusable widgets
├── assets/                  # Images, fonts, animations
└── pubspec.yaml            # Dependencies
```

### Backend (Node.js + PostgreSQL)
```
travel_sync_backend/
├── src/
│   ├── config/             # Database, passport, swagger config
│   ├── controllers/        # Route controllers
│   ├── middleware/         # Custom middleware
│   ├── models/            # Database models (Objection.js)
│   ├── routes/            # API routes
│   ├── services/          # Business logic services
│   ├── utils/             # Utility functions
│   └── database/
│       ├── migrations/    # Database migrations
│       └── seeds/         # Database seeds
├── tests/                 # Test files
└── package.json          # Dependencies
```

## 🛠️ Tech Stack

### Mobile App (Flutter)
- **Framework**: Flutter 3.10+
- **State Management**: BLoC Pattern
- **Navigation**: GoRouter
- **Local Storage**: Hive + SQLite
- **Network**: Dio + Retrofit
- **Maps**: Google Maps / OpenStreetMap
- **Authentication**: Firebase Auth
- **Background Tasks**: Workmanager
- **Media**: Cloudinary SDK

### Backend API
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL 14+
- **ORM**: Objection.js + Knex.js
- **Authentication**: JWT + Passport.js
- **File Upload**: Multer + Cloudinary
- **Real-time**: Socket.io
- **Documentation**: Swagger/OpenAPI

### Infrastructure
- **Database**: PostgreSQL (primary), Redis (caching)
- **File Storage**: Cloudinary
- **Background Jobs**: Bull Queue
- **Logging**: Winston
- **Monitoring**: Custom analytics

## 📱 Installation & Setup

### Prerequisites
- Flutter SDK 3.10+
- Node.js 18+
- PostgreSQL 14+
- Redis (optional, for caching)
- Cloudinary account
- Firebase project (for authentication)

### Flutter App Setup

1. **Install Flutter dependencies**:
```bash
cd travel_sync_app
flutter pub get
```

2. **Generate code**:
```bash
flutter packages pub run build_runner build
```

3. **Configure Firebase**:
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `lib/core/config/app_config.dart`

4. **Configure Cloudinary**:
   - Update Cloudinary credentials in `lib/core/config/app_config.dart`

5. **Run the app**:
```bash
flutter run
```

### Backend Setup

1. **Install dependencies**:
```bash
cd travel_sync_backend
npm install
```

2. **Environment configuration**:
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Database setup**:
```bash
# Create PostgreSQL database
createdb travelsync_db

# Run migrations
npm run migrate

# Seed database (optional)
npm run seed
```

4. **Start the server**:
```bash
# Development
npm run dev

# Production
npm start
```

### Environment Variables

#### Backend (.env)
```env
NODE_ENV=development
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=travelsync_db
JWT_SECRET=your_jwt_secret
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
```

## 🧪 Testing

### Flutter Tests
```bash
cd travel_sync_app
flutter test
```

### Backend Tests
```bash
cd travel_sync_backend
npm test
```

## 📊 API Documentation

The API documentation is available at `/api-docs` when running the backend server.

Key endpoints:
- `POST /api/v1/auth/login` - User authentication
- `GET /api/v1/trips` - Get user trips
- `POST /api/v1/trips` - Create new trip
- `POST /api/v1/expenses` - Add expense
- `GET /api/v1/analytics/travel-insights` - Get travel analytics

## 🔒 Security Features

- **Data Encryption**: All sensitive data encrypted at rest and in transit
- **Authentication**: Multi-factor authentication support
- **Authorization**: Role-based access control
- **Privacy**: GDPR-compliant data handling
- **Audit Logging**: Comprehensive activity logging

## 🌐 Offline Support

- **Local Storage**: Hive database for offline data storage
- **Background Sync**: Automatic synchronization when online
- **Conflict Resolution**: Smart merge strategies for data conflicts
- **Offline Maps**: Cached map data for offline navigation

## 📈 Analytics & Research

### For NATPAC Researchers
- **Data Export**: CSV/Excel export of anonymized travel data
- **Travel Patterns**: Analysis of mobility patterns and trends
- **Mode Choice**: Understanding of transportation mode preferences
- **Temporal Analysis**: Time-based travel behavior insights

### Admin Dashboard
- **User Management**: User account administration
- **Data Monitoring**: Real-time data collection monitoring
- **Export Tools**: Bulk data export capabilities
- **Analytics**: Comprehensive travel behavior analytics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation at `/api-docs`

## 🚀 Deployment

### Flutter App
- **Android**: Build APK/AAB for Google Play Store
- **iOS**: Build IPA for Apple App Store
- **Web**: Deploy to Firebase Hosting or Netlify

### Backend
- **Production**: Deploy to AWS, Google Cloud, or Azure
- **Database**: Use managed PostgreSQL service
- **Monitoring**: Set up logging and monitoring
- **SSL**: Configure HTTPS with SSL certificates

## 📋 Roadmap

- [ ] Machine Learning trip prediction
- [ ] Advanced analytics dashboard
- [ ] Integration with public transport APIs
- [ ] Carbon footprint calculation
- [ ] Social features and trip sharing
- [ ] Wearable device integration
- [ ] Voice commands and AI assistant

---

**TravelSync** - Empowering travel research through intelligent data collection and user-friendly trip planning.
