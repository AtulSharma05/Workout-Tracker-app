# 🏋️ Workout Tracker App

A full-stack workout tracking application with Flutter frontend and Node.js/Express/MongoDB backend. Track your fitness journey with real-time analytics, achievements, and rewards system.

## ✨ Features

### 🎯 Core Features
- **Workout Logging** - Track exercises with sets, reps, weight, duration, and calories
- **Workout Types** - Strength Training, Cardio, Flexibility, Sports
- **Real-time Analytics** - Visual charts and statistics of your progress
- **Streak Tracking** - Monitor consecutive workout days
- **Recent Workouts** - Quick view of your latest activities

### 🏆 Gamification
- **Points System** - Earn points from completing achievements
- **Achievements** - 7 unlockable achievements (First Steps, Consistency, Weekly Warrior, etc.)
- **Rewards** - Unlock features with points (Custom Themes, Advanced Stats, etc.)
- **Tokens** - Blockchain-based rewards for future live challenges (Coming Soon)

### 📊 Analytics
- **Overview Cards** - Total workouts, streak, time, calories
- **Weekly Progress** - Bar chart showing workout frequency
- **Workout Distribution** - Pie chart of workout types
- **Top Exercises** - Most performed exercises ranked

### 👤 Profile
- **User Information** - Display name, email, avatar with initials
- **Stats Dashboard** - Total workouts, minutes, calories, averages
- **Workout Breakdown** - Distribution by type
- **Achievement Badges** - Visual progress indicators
- **Streak Milestones** - Progress to next milestone (7/14/30/60/100/365 days)

### 🔐 Authentication
- **JWT-based** - Secure token authentication
- **User Registration** - Create account with email, username, full name
- **Login/Logout** - Persistent sessions with secure token storage

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
   - Update MongoDB connection string if needed (default: `mongodb://localhost:27017/workout_tracker_db`)
   - Update JWT secret for production

4. **Start MongoDB** (if not running):
   ```bash
   # Windows (if MongoDB installed as service)
   net start MongoDB
   
   # Mac/Linux
   mongod
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

- Backend CORS is configured to accept all origins in development
- If issues persist, check backend console logs

## 🔐 Security Features

- **JWT Authentication** - Secure token-based auth with 7-day expiration
- **Secure Storage** - Tokens stored in flutter_secure_storage
- **Password Hashing** - bcrypt with 12 rounds
- **Input Validation** - Server-side validation for all requests
- **User ID Extraction** - Automatic userId from JWT (not sent in requests)

## 📦 Key Dependencies

### Backend
- express, mongoose, cors
- bcryptjs, jsonwebtoken
- helmet, morgan

### Frontend
- dio (HTTP client)
- provider (state management)
- fl_chart (data visualization)
- connectivity_plus (network checking)
- flutter_secure_storage (token storage)

## 🚀 Future Enhancements

- [ ] Social features & community
- [ ] Workout plans & templates
- [ ] AI workout recommendations
- [ ] Progress photos & body measurements
- [ ] Dark mode
- [ ] Export workout data (CSV/PDF)
- [ ] Rest timer for sets
- [ ] Push notifications
- [ ] Exercise library with instructions
- [ ] Advanced analytics & personal records

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


**Note:** This app requires an active backend connection. The app is designed to work exclusively with the backend API for data persistence and authentication.
