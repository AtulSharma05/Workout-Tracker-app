# 🏗️ Project Architecture & Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP (Frontend)                  │
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Views/    │  │ Controllers/ │  │   Widgets/   │      │
│  │  Screens    │◄─┤    State     │  │  Components  │      │
│  └──────┬──────┘  └──────┬───────┘  └──────────────┘      │
│         │                │                                  │
│         └────────────────┘                                  │
│                 │                                           │
│         ┌───────▼────────┐                                 │
│         │   Services/    │                                 │
│         │                │                                 │
│         │  ┌──────────┐  │                                 │
│         │  │  Auth    │  │                                 │
│         │  │ Service  │  │                                 │
│         │  └────┬─────┘  │                                 │
│         │       │        │                                 │
│         │  ┌────▼─────┐  │                                 │
│         │  │ Workout  │  │                                 │
│         │  │ Service  │  │                                 │
│         │  └────┬─────┘  │                                 │
│         │       │        │                                 │
│         │  ┌────▼─────┐  │                                 │
│         │  │   API    │◄─┼──┐                              │
│         │  │ Service  │  │  │                              │
│         │  └────┬─────┘  │  │                              │
│         │       │        │  │                              │
│         │  ┌────▼──────┐ │  │  ┌──────────────┐           │
│         │  │Connectivity│ │  └──┤ Config/      │           │
│         │  │  Service   │ │     │ api_config   │           │
│         │  └────────────┘ │     └──────────────┘           │
│         └────────┬─────────┘                                │
│                  │                                          │
└──────────────────┼──────────────────────────────────────────┘
                   │
                   │ HTTP/HTTPS
                   │ (Platform-specific URLs)
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│              NODE.JS BACKEND (Express + MongoDB)            │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              server.js (Entry Point)                 │  │
│  │  • CORS: origin: '*'                                 │  │
│  │  • Listen: 0.0.0.0:3000                              │  │
│  │  • Rate Limiting                                     │  │
│  └────────────────┬─────────────────────────────────────┘  │
│                   │                                         │
│         ┌─────────┴─────────┐                              │
│         │                   │                              │
│    ┌────▼────┐         ┌────▼────┐                         │
│    │ Routes  │         │ Routes  │                         │
│    │  Auth   │         │ Workout │                         │
│    └────┬────┘         └────┬────┘                         │
│         │                   │                              │
│    ┌────▼────────┐    ┌────▼──────────┐                   │
│    │ Controllers │    │  Controllers  │                   │
│    │   Auth      │    │   Workout     │                   │
│    └────┬────────┘    └────┬──────────┘                   │
│         │                   │                              │
│    ┌────▼────────┐    ┌────▼──────────┐                   │
│    │   Models    │    │    Models     │                   │
│    │    User     │    │   Workout     │                   │
│    └────┬────────┘    └────┬──────────┘                   │
│         │                   │                              │
│         └─────────┬─────────┘                              │
│                   │                                         │
│              ┌────▼────┐                                   │
│              │ MongoDB │                                   │
│              │Database │                                   │
│              └─────────┘                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Request Flow (Example: User Login)

```
1. USER ACTION
   └─► User enters email/password and taps "Login"

2. VIEW LAYER
   └─► LoginScreen validates input
       └─► Calls AuthController.login()

3. CONTROLLER LAYER  
   └─► AuthController prepares data
       └─► Calls AuthService.login()

4. SERVICE LAYER
   └─► AuthService.login()
       ├─► Calls ConnectivityService.checkConnectivity()
       │   ├─► ✅ Connected? Continue
       │   └─► ❌ Not connected? Throw error "No internet connection"
       │
       └─► Calls ApiService.post('/auth_user/login', data)
           └─► ApiService adds interceptors:
               ├─► Logs request (🌐 REQUEST[POST])
               ├─► Adds headers (Content-Type, Authorization)
               └─► Sends HTTP POST request

5. NETWORK LAYER
   Platform-specific URL resolution:
   ├─► Android Emulator → http://10.0.2.2:3000/api/v1/auth_user/login
   ├─► iOS Simulator    → http://localhost:3000/api/v1/auth_user/login
   └─► Physical Device  → http://192.168.x.x:3000/api/v1/auth_user/login

6. BACKEND RECEIVES REQUEST
   └─► Express middleware chain:
       ├─► CORS check (✅ Allowed)
       ├─► Rate limiter
       ├─► Body parser
       └─► Routes to: /api/v1/auth_user/login

7. BACKEND PROCESSING
   └─► routes/frontendAuth.js
       └─► Calls authController.login()
           ├─► Validates credentials
           ├─► Queries MongoDB (User model)
           ├─► Generates JWT token
           └─► Returns response

8. BACKEND RESPONSE
   └─► JSON: { success: true, token: "...", user: {...} }

9. FLUTTER RECEIVES RESPONSE
   └─► ApiService interceptor logs (✅ RESPONSE[200])
       └─► Returns response to AuthService

10. SERVICE PROCESSES RESPONSE
    └─► AuthService.login()
        ├─► Saves token to FlutterSecureStorage
        ├─► Sets token in ApiService for future requests
        └─► Returns {success: true, user: User(...)}

11. CONTROLLER UPDATES STATE
    └─► AuthController notifies listeners
        └─► UI rebuilds

12. UI UPDATE
    └─► Navigate to Home Screen
        └─► Show success message
```

---

## Error Handling Flow

```
SCENARIO: Backend is not running

1. User taps "Login"
   ├─► ConnectivityService.checkConnectivity()
   │   └─► ✅ Phone has internet (WiFi/Mobile data)
   │
   ├─► ApiService.post() attempts connection
   │   └─► ❌ Connection refused (backend not running)
   │
   ├─► ApiService._handleError()
   │   └─► Creates Exception: "Connection error. Please check if the backend server is running."
   │
   ├─► AuthService catches exception
   │   └─► Returns {success: false, error: "..."}
   │
   ├─► Controller receives error
   │   └─► Updates state with error message
   │
   └─► UI shows error
       ├─► SnackBar: "Backend connection failed: ..."
       ├─► Connection status card turns RED
       └─► User sees CLEAR error message

✅ No silent fallback to Hive!
✅ User knows exactly what's wrong!
```

---

## Data Flow Patterns

### Pattern 1: Create Workout

```
View (CreateWorkoutScreen)
  │
  ├─► User fills form
  ├─► Validates input
  └─► Calls WorkoutController.createWorkout()
      │
      └─► WorkoutController
          └─► Calls WorkoutService.createWorkout(workout)
              │
              └─► WorkoutService
                  ├─► Check connectivity
                  └─► ApiService.post('/workout_logging', data)
                      │
                      └─► Backend API
                          ├─► Validates data
                          ├─► Saves to MongoDB
                          └─► Returns created workout
                              │
                              └─► Flutter receives workout
                                  ├─► Parse JSON → Workout model
                                  ├─► Optionally cache in Hive
                                  ├─► Notify UI
                                  └─► Show success message
```

### Pattern 2: Fetch Workouts

```
View (WorkoutListScreen)
  │
  └─► onInit() or Pull-to-Refresh
      │
      └─► WorkoutController.loadWorkouts()
          │
          └─► WorkoutService.getWorkouts()
              │
              ├─► Check connectivity
              │   ├─► ✅ Online: Fetch from backend
              │   │   ├─► GET /workout_logging
              │   │   ├─► Receive List<Workout>
              │   │   ├─► Cache in Hive (for offline)
              │   │   └─► Update UI
              │   │
              │   └─► ❌ Offline: Try Hive cache
              │       ├─► Load from Hive
              │       ├─► Show "Offline mode" indicator
              │       └─► Display cached data
              │
              └─► Return workouts to controller
```

---

## Directory Structure Mapping

```
Backend Structure → Frontend Structure
═══════════════════════════════════════

backend/src/models/User.js
    └─► frontend/lib/models/user.dart

backend/src/models/Workout.js
    └─► frontend/lib/models/workout.dart

backend/src/controllers/workoutController.js
    └─► frontend/lib/services/workout_service.dart
        └─► frontend/lib/controllers/workout_controller.dart (to create)

backend/src/routes/frontendAuth.js
    └─► frontend/lib/services/auth_service.dart

backend/src/middleware/auth.js
    └─► frontend/lib/services/api_service.dart (token management)
```

---

## State Management (Provider Pattern)

```
main.dart
  │
  └─► MultiProvider wraps MaterialApp
      │
      ├─► Provider<ConnectivityService>
      ├─► Provider<ApiService>
      ├─► Provider<AuthService>
      └─► Provider<WorkoutService>
          │
          └─► Available to entire widget tree
              │
              └─► Any widget can access via:
                  • context.read<AuthService>()
                  • context.watch<AuthService>()
                  • Provider.of<AuthService>(context)
```

---

## URL Resolution Logic

```dart
// frontend/lib/config/api_config.dart

Platform Detection:
┌────────────────────────────────────────┐
│ Platform.isAndroid?                    │
├────────────────────────────────────────┤
│ YES → Android Emulator                 │
│       URL: http://10.0.2.2:3000/api/v1│
│       (10.0.2.2 = host machine)        │
├────────────────────────────────────────┤
│ Platform.isIOS?                        │
├────────────────────────────────────────┤
│ YES → iOS Simulator                    │
│       URL: http://localhost:3000/api/v1│
├────────────────────────────────────────┤
│ ELSE → Physical Device                 │
│       URL: http://192.168.x.x:3000/api/v1│
│       (Network IP - must configure)    │
└────────────────────────────────────────┘
```

---

## Security Flow

```
JWT Authentication:

1. Login
   └─► Backend generates JWT token
       └─► Includes: {userId, email, exp}

2. Flutter stores token
   └─► FlutterSecureStorage (encrypted)
       └─► Key: 'auth_token'

3. Subsequent requests
   └─► ApiService interceptor adds header:
       Authorization: Bearer eyJhbGc...

4. Backend validates token
   └─► middleware/auth.js
       ├─► Verifies JWT signature
       ├─► Checks expiration
       └─► Attaches user to request

5. Protected routes
   └─► Only accessible with valid token
```

---

## Offline/Online Strategy

```
┌─────────────────────────────────────┐
│      Connectivity Service           │
│                                     │
│  1. Check network status            │
│  2. Listen to changes               │
│  3. Notify listeners                │
└────────────┬────────────────────────┘
             │
             ├─► ONLINE
             │   ├─► Fetch from backend
             │   ├─► Cache in Hive
             │   └─► Sync pending changes
             │
             └─► OFFLINE
                 ├─► Load from Hive cache
                 ├─► Show offline indicator
                 ├─► Queue changes locally
                 └─► Sync when back online
```

---

This architecture ensures:
- ✅ Clear separation of concerns
- ✅ Easy to test each layer
- ✅ No silent failures
- ✅ Proper error propagation
- ✅ Platform-agnostic design
- ✅ Scalable structure
