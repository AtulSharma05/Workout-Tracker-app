# Flutter Pose Detection - Quick Start Guide

## 🚀 Quick Start (3 Steps)

### Step 1: Start Backend Services
```powershell
# In project root directory
.\START_SERVICES.ps1
```

Wait for all services to start (should see 3 PowerShell windows):
- ✅ Node.js Backend (Port 3000)
- ✅ AI Planner (Port 8000)  
- ✅ Pose Corrector (Port 8001)

### Step 2: Run Flutter App
```bash
cd frontend
flutter run
```

**Choose your device:**
- Android emulator: Press `1`
- Chrome browser: Press `2`
- Physical device: Make sure it's connected

### Step 3: Test Pose Detection
1. **Login** to the app (or register if new user)
2. From dashboard, tap **"Features"**
3. Scroll and tap **"Pose Detection"** card (now has "AI" badge, not "Coming Soon")
4. **Grant camera permission** when prompted
5. **Start exercising!** Do push-ups, squats, or any exercise

You should see:
- 📹 Live camera preview
- 🔢 Rep counter at top
- 🎯 Phase indicator (UP/DOWN/HOLD)
- 💡 Real-time form tips
- 📊 FPS counter at bottom

## 📱 What to Expect

### First Launch
1. App will request camera permission - **tap "Allow"**
2. Camera will initialize (may take 2-3 seconds)
3. "Connecting to pose analysis service..." message appears
4. Once connected, you'll see "Ready" phase indicator

### During Exercise
- Start doing push-ups or squats
- Rep counter will increment automatically
- Phase shows "UP" during raising motion, "DOWN" during lowering
- Form tips appear if posture needs correction
- FPS shows processing speed (target: 20-30 FPS)

### Finishing Workout
- Tap ✓ (checkmark) icon in top right
- See summary: Total reps, duration, form score
- Tap "Done" to return to features

### Reset/Restart
- Tap 🔄 (refresh) icon to reset rep count
- Continues tracking without reconnecting

## 🎯 Testing Scenarios

### Test 1: Basic Rep Counting
1. Open pose detection
2. Do 5 slow push-ups
3. Verify counter shows "5"
4. ✅ Pass if count is accurate

### Test 2: Form Feedback
1. Do push-ups with intentionally poor form (e.g., sagging back)
2. Check if form tips appear
3. ✅ Pass if feedback is relevant

### Test 3: Different Exercises
1. Reset session
2. Try squats instead
3. Verify counting still works
4. ✅ Pass if adapts to different movements

### Test 4: Session Summary
1. Complete 10 reps
2. Tap checkmark icon
3. Verify summary shows correct data
4. ✅ Pass if summary appears

## 🔧 Troubleshooting

### "Camera permission denied"
**Fix:** Go to phone Settings → Apps → Workout Tracker → Permissions → Enable Camera

### "Failed to connect to pose analysis service"
**Fix:** 
1. Check pose corrector is running: Open `http://localhost:8001/health` in browser
2. Should see `{"status":"healthy"}`
3. If not running, restart with `.\START_SERVICES.ps1`

### "No cameras found"
**Fix:** Make sure emulator/device has camera enabled
- Android Emulator: Settings → Virtual Camera (enable)
- Physical device: Test with default camera app first

### Reps not counting
**Possible causes:**
- Not enough lighting (MediaPipe needs good visibility)
- Full body not visible in frame
- Camera too far away
- Exercise movement too subtle

**Fixes:**
- Ensure good lighting
- Position camera to see full body
- Move closer to camera (2-3 meters ideal)
- Make movements more pronounced

### Low FPS (below 15)
**Fixes:**
- Close other apps running on device
- Restart pose corrector service
- Check computer CPU usage (pose corrector process)

### App crashes on launch
**Fix:**
```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

## 📊 Expected Performance

| Metric | Target | Acceptable |
|--------|--------|------------|
| FPS | 25-30 | 15-20 |
| Connection Time | < 2s | < 5s |
| Rep Count Accuracy | 95%+ | 85%+ |
| Form Feedback Delay | < 500ms | < 1s |

## 🎥 Supported Exercises

Currently tested and working:
- ✅ Push-ups (all variations)
- ✅ Squats (bodyweight, barbell)
- ✅ Lunges (forward, reverse)
- ✅ Plank hold
- ✅ Shoulder press
- ✅ Bicep curls

More exercises coming soon! The system can detect 1,451 different exercise patterns.

## 📱 Device Requirements

**Minimum:**
- Android 6.0+ or iOS 10+
- Camera (front or rear)
- 2GB RAM
- Network connection to backend

**Recommended:**
- Android 10+ or iOS 13+
- 4GB+ RAM
- Good lighting conditions
- WiFi connection (for best performance)

## 🔗 Important URLs

**Backend Services:**
- Node.js API: `http://localhost:3000`
- AI Planner: `http://localhost:8000`
- Pose Corrector: `http://localhost:8001`
- Pose WebSocket: `ws://localhost:8001/ws/pose-analysis`

**API Docs:**
- Pose API Docs: `http://localhost:8001/docs` (interactive)

## 📝 Next Steps After Testing

Once basic functionality works:

1. **Exercise Selection:** Add UI to choose specific exercise before starting
2. **Workout Logging:** Auto-save completed reps to workout history
3. **Progress Tracking:** Show improvement over time
4. **Multi-Set Support:** Track sets with rest timers
5. **Social Features:** Share workout videos with pose overlay

## ✅ Integration Checklist

Mark these off as you test:

- [ ] Backend services running (all 3)
- [ ] Flutter app builds and runs
- [ ] Features page shows "Pose Detection" enabled
- [ ] Tapping card opens camera
- [ ] Camera permission granted
- [ ] Camera preview shows correctly
- [ ] WebSocket connects successfully
- [ ] Rep counter updates during exercise
- [ ] Phase indicator changes (UP/DOWN)
- [ ] Form feedback appears
- [ ] FPS counter shows 15+ FPS
- [ ] Reset button works
- [ ] Finish workout shows summary
- [ ] Can return to features page

If all checked: **🎉 Integration successful!**

## 🆘 Getting Help

If you encounter issues not covered here:

1. Check `FLUTTER_POSE_INTEGRATION.md` for detailed technical info
2. Review backend logs in PowerShell windows
3. Check Flutter console output for errors
4. Test API endpoints directly: `http://localhost:8001/docs`

---

**Ready to test? Run `.\START_SERVICES.ps1` and `flutter run`!** 🚀
