# AI Workout Planner Integration - Testing Guide

## ✅ What's Been Completed

### Backend Integration
1. **Python AI Server** (Port 8000)
   - ✅ Copied from `personalised_workout_planner` folder
   - ✅ All dependencies installed (FastAPI, scikit-learn, pandas, etc.)
   - ✅ Running successfully on `http://localhost:8000`
   - ✅ Health check working: `GET /health`
   - ✅ Plan generation working: `POST /plan`

2. **Node.js Backend** (Port 3000)
   - ✅ Service wrapper created: `src/services/aiPlannerService.js`
   - ✅ Controller created: `src/controllers/workoutPlanController.js`
   - ✅ Routes created: `src/routes/workoutPlanRoutes.js`
   - ✅ All routes require authentication (JWT)
   - ✅ API endpoints:
     - `POST /api/v1/workout-plans/generate` - Generate AI workout plan
     - `POST /api/v1/workout-plans/recommend-exercises` - Get exercise recommendations
     - `POST /api/v1/workout-plans/predict-sets` - Predict sets/reps
     - `GET /api/v1/workout-plans/status` - Check AI service status

3. **Frontend Integration**
   - ✅ Models created: `lib/models/workout_plan.dart`
   - ✅ Service created: `lib/services/workout_plan_service.dart`
   - ✅ UI page created: `lib/pages/create_workout_plan_page.dart`
   - ✅ Features page updated with "AI Powered" badge
   - ✅ Route added to main.dart
   - ✅ WorkoutPlanService registered in Provider
   - ✅ No compilation errors

## 🔧 Current Status

### Python Server
- **Status**: ✅ Running
- **Port**: 8000
- **Process**: Started via PowerShell with Python 3.13
- **Test Command**: 
  ```powershell
  Invoke-WebRequest -Uri "http://localhost:8000/health" -Method GET -UseBasicParsing
  ```
- **Response**: `{"status":"healthy","ml_model":"available","llm":"available"}`

### Node.js Backend
- **Status**: ✅ Running
- **Port**: 3000
- **Database**: MongoDB connected
- **Test**: Server starts successfully, no errors

### Frontend
- **Status**: ⏳ Not tested yet
- **Compilation**: ✅ No errors

## 🧪 What Needs Testing

### 1. End-to-End Flow (Priority: HIGH)
Test the complete user journey:
1. Start Flutter app
2. Login as existing user
3. Navigate to Features page
4. Click "Workout Plans" card
5. Fill out the form:
   - Select goal (muscle gain/weight loss/general fitness)
   - Select experience level
   - Choose days per week (1-7)
   - Select equipment
   - Select target muscles (optional)
   - Set duration
6. Click "Generate AI Workout Plan"
7. Verify plan is generated and displayed

**Expected Result**: AI-generated workout plan displayed with exercises, sets, reps

### 2. Backend API Testing (Priority: MEDIUM)
Test Node.js endpoints directly:

```bash
# Test status endpoint (requires auth token)
curl -X GET http://localhost:3000/api/v1/workout-plans/status \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Test plan generation (requires auth token)
curl -X POST http://localhost:3000/api/v1/workout-plans/generate \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "goal": "muscle_gain",
    "experience": "intermediate",
    "daysPerWeek": 4,
    "equipment": ["Dumbbell", "Barbell"],
    "targetMuscles": ["Chest", "Back"]
  }'
```

**Expected Result**: Returns workout plan in expected format

### 3. Error Handling (Priority: MEDIUM)
Test error scenarios:
- What happens if Python server is stopped?
- What happens if invalid data is submitted?
- What happens if user is not authenticated?

**Expected Behavior**:
- Graceful error messages
- Service status indicator shows offline
- Form validation prevents bad requests

### 4. Python Server Persistence (Priority: HIGH)
**Issue**: Python server started manually via PowerShell
**Solution Needed**: 
- Option A: Start Python server automatically when Node.js starts
- Option B: Run Python server as a separate service
- Option C: Use PM2 or similar to manage both processes

Current approach in `aiPlannerService.js`:
```javascript
async startPythonServer() {
  // This spawns Python process from Node.js
  // Not currently being called
}
```

## 📋 Testing Checklist

- [ ] Python server stays running
- [ ] Node.js backend starts without errors
- [ ] Flutter app compiles and runs
- [ ] Can navigate to Workout Plans page
- [ ] Form validation works
- [ ] Service status indicator works
- [ ] Plan generation works end-to-end
- [ ] Generated plan displays correctly
- [ ] Error handling works (when Python server offline)
- [ ] Can create multiple plans
- [ ] Authentication is enforced

## 🚀 How to Start Everything

### Terminal 1: Python AI Server
```powershell
cd "c:\Users\hp\Desktop\new\backend\ai-planner"
C:\Users\hp\AppData\Local\Programs\Python\Python313\python.exe api_server.py
```

### Terminal 2: MongoDB (if not running as service)
```powershell
cd "c:\Users\hp\Desktop\new\backend"
npm run mongo
```

### Terminal 3: Node.js Backend
```powershell
cd "c:\Users\hp\Desktop\new\backend"
node src/server.js
```

### Terminal 4: Flutter App
```powershell
cd "c:\Users\hp\Desktop\new\frontend"
flutter run
```

## ⚠️ Known Issues

1. **Python Server Not Auto-Starting**
   - Currently must be started manually
   - Need to decide on deployment strategy

2. **Plan Display Format**
   - Python API returns text-based plan
   - Frontend model expects structured days/exercises
   - **Solution**: Display plan as formatted text for now, improve parsing later

3. **Exercise Recommendations**
   - Python API doesn't have `/recommend-exercises` endpoint
   - Currently using mock data in `aiPlannerService.js`
   - **Future**: Enhance Python API or use exercise database directly

## 📝 Next Steps (After Testing)

1. Test end-to-end integration
2. Fix any bugs discovered
3. Improve plan parsing (convert text to structured format)
4. Add plan saving to MongoDB
5. Add plan history viewing
6. Implement Python server auto-start
7. Commit all changes to git
8. Update README with AI planner documentation

## 🔗 Important Files

**Backend**:
- `backend/ai-planner/api_server.py` - Python FastAPI server
- `backend/src/services/aiPlannerService.js` - Node.js wrapper
- `backend/src/controllers/workoutPlanController.js` - Request handlers
- `backend/src/routes/workoutPlanRoutes.js` - Route definitions
- `backend/test-ai-planner.js` - Integration test script

**Frontend**:
- `frontend/lib/pages/create_workout_plan_page.dart` - Main UI
- `frontend/lib/services/workout_plan_service.dart` - API client
- `frontend/lib/models/workout_plan.dart` - Data models
- `frontend/lib/config/api_config.dart` - API endpoints

**Configuration**:
- Python dependencies: `backend/ai-planner/requirements.txt`
- Node dependencies: `backend/package.json`
- Flutter dependencies: `frontend/pubspec.yaml`
