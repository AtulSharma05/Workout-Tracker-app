# Workout Tracker App

Full-stack workout tracking application with Flutter frontend and Node.js/Express/MongoDB backend.

## 🎯 Project Structure

```
new/
├── backend/          # Node.js Express API Server
│   ├── src/
│   │   ├── config/   # Database configuration
│   │   ├── models/   # MongoDB schemas (User, Workout)
│   │   ├── controllers/  # Business logic
│   │   ├── routes/   # API routes
│   │   ├── middleware/   # Auth, error handling
│   │   └── server.js     # Entry point
│   └── package.json
│
└── frontend/         # Flutter Mobile App
    ├── lib/
    │   ├── config/   # API configuration
    │   ├── models/   # Data models
    │   ├── services/ # API & connectivity services
    │   ├── controllers/  # State management
    │   ├── views/    # UI screens
    │   ├── widgets/  # Reusable components
    │   └── utils/    # Helpers
    └── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites
- **Node.js** (v16+)
- **MongoDB** (v5+)
- **Flutter** (v3.0+)
- **Android Studio** or **Xcode** (for mobile development)

### Backend Setup

1. **Navigate to backend folder:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   - Copy `.env.example` to `.env`
   - Update MongoDB connection string and other settings

4. **Start MongoDB:**
   ```bash
   npm run mongo
   ```

5. **Start backend server:**
   ```bash
   npm run dev
   ```

   The server will start on `http://0.0.0.0:3000` (accessible from network devices)

### Frontend Setup

1. **Navigate to frontend folder:**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **IMPORTANT: Update API Configuration**
   
   Open `lib/config/api_config.dart` and update the network IP:
   
   ```dart
   static const String _networkIP = '192.168.1.100'; // REPLACE WITH YOUR LOCAL IP
   ```
   
   **Find your local IP:**
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🔧 Connectivity Configuration

### ✅ What's Already Fixed

1. **Backend CORS Configuration**
   - Accepts requests from all origins during development
   - Listens on `0.0.0.0` for network accessibility

2. **Flutter Platform-Specific URLs**
   - Android Emulator: `http://10.0.2.2:3000`
   - iOS Simulator: `http://localhost:3000`
   - Physical Devices: `http://<your-network-ip>:3000`

3. **Internet Permissions**
   - Android: Added to `AndroidManifest.xml`
   - iOS: Configured in `Info.plist`

4. **Connectivity Checker**
   - Validates network connection before API calls
   - Shows clear error messages instead of silent fallback

5. **HTTP Client with Logging**
   - Logs all requests/responses for debugging
   - Automatic token management
   - Comprehensive error handling

## 📱 Testing the Connection

### Step 1: Start Backend
```bash
cd backend
npm run dev
```

You should see:
```
🚀 Workout Tracker Backend Server running on port 3000
📍 Local URL: http://localhost:3000/api/v1
📍 Network URL: http://<your-local-ip>:3000/api/v1
```

### Step 2: Test Backend Health
Visit in browser: `http://localhost:3000/health`

### Step 3: Run Flutter App

**For Android Emulator:**
- No changes needed, uses `10.0.2.2` automatically

**For Physical Device:**
1. Ensure phone and computer are on the same WiFi
2. Update `_networkIP` in `lib/config/api_config.dart`
3. Run: `flutter run`

### Step 4: Monitor Logs

**Backend logs** will show incoming requests:
```
🌐 REQUEST[POST] => http://10.0.2.2:3000/api/v1/auth_user/login
```

**Flutter logs** will show:
```
🌐 REQUEST[POST] => http://10.0.2.2:3000/api/v1/auth_user/login
📤 Headers: {Content-Type: application/json}
✅ RESPONSE[200]
```

## 🛠️ Troubleshooting

### "Connection refused" or "Network error"

1. **Check if backend is running:**
   ```bash
   curl http://localhost:3000/health
   ```

2. **Check firewall settings:**
   - Windows: Allow Node.js through Windows Firewall
   - Mac: System Preferences → Security & Privacy → Firewall

3. **Verify network IP is correct:**
   - Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
   - Update `api_config.dart` with correct IP

4. **For physical devices:**
   - Ensure phone and computer are on same WiFi network
   - Some corporate/public WiFi networks block device-to-device communication

### "CORS error"

- Already fixed in backend `server.js`
- If still occurring, check backend console logs

### App uses Hive instead of backend

- Check Flutter logs for connectivity errors
- Connectivity checker should show error messages
- Verify API base URL is correct

## 📚 API Endpoints

### Authentication
- `POST /api/v1/auth_user/register` - Register new user
- `POST /api/v1/auth_user/login` - Login user

### Workouts
- `GET /api/v1/workout_logging` - Get all workouts
- `GET /api/v1/workout_logging/:id` - Get specific workout
- `POST /api/v1/workout_logging` - Create workout
- `PUT /api/v1/workout_logging/:id` - Update workout
- `DELETE /api/v1/workout_logging/:id` - Delete workout

## 🎨 Architecture

### Backend: MVC Pattern
- **Models**: MongoDB schemas with Mongoose
- **Views**: JSON responses
- **Controllers**: Business logic
- **Routes**: API endpoint definitions

### Frontend: Clean Architecture
- **Models**: Data models with JSON serialization
- **Services**: API communication layer
- **Controllers**: State management (Provider)
- **Views**: UI screens
- **Widgets**: Reusable components

### Data Flow
```
User Action → Controller → Service → API → Backend
            ←            ←         ←       ←
         Update UI    Response   JSON   Database
```

## 🔐 Security Features

- JWT authentication
- Secure token storage (flutter_secure_storage)
- Request rate limiting
- Helmet.js security headers
- Input validation

## 📦 Key Dependencies

### Backend
- express, mongoose, cors
- bcryptjs, jsonwebtoken
- helmet, morgan, express-rate-limit

### Frontend
- dio (HTTP client)
- provider (state management)
- hive (local caching)
- connectivity_plus (network checking)
- flutter_secure_storage (token storage)

## 🚧 Next Steps

1. Implement complete authentication flow
2. Build workout CRUD UI screens
3. Add offline-first architecture with Hive caching
4. Implement workout history and analytics
5. Add exercise library
6. Implement progress tracking

---

**Important:** This project ensures the Flutter app ALWAYS connects to the backend. Hive is configured as an offline cache only, not as a silent fallback when connectivity issues occur.
