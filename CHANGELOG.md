# Changelog

All notable changes to the Workout Tracker App will be documented in this file.

## [2.0.0] - November 16, 2025

### 🎉 Major Features Added

#### AI-Powered Workout Planning
- **7-Day Personalized Plans** - Full week workout schedules with ML-based predictions
- **Duration-Based Scaling** - Workouts adapt to time selection (30/60/90 minutes)
  - 30 min = 2 exercises per muscle group
  - 60 min = 3 exercises per muscle group  
  - 90 min = 5 exercises per muscle group
- **Round-Robin Exercise Distribution** - Balanced exercise allocation across all training days
- **Natural Language Input Parser** - Supports 1-7 training days per week
- **Rest Day Management** - Automatic rest day placement with recovery messaging

#### Exercise Database Integration
- **1500+ Exercise Library** - Comprehensive database with detailed information
- **Animated GIF Demonstrations** - Click-to-view exercise animations
- **Exercise Details Dialog** - Shows GIF, instructions, target muscles, and equipment
- **Exercise Search API** - Backend endpoint for searching exercises by name/muscle
- **Caching System** - Flutter service caches exercise data for performance

### 🐛 Bug Fixes
- Fixed back button navigation on Profile, Analytics, and Features pages
  - Now returns to HomePage instead of Login page
- Fixed 7-day workout plan generation (previously limited to 6 days)
- Fixed missing workout days in 5-7 day plans
- Fixed Pydantic validation error in Python API (structured_data type)
- Resolved exercise distribution issues that left days empty

### 🔧 Technical Improvements
- Enhanced natural language parser to extract workout duration
- Improved exercise parameter prediction with duration awareness
- Added HomePage import to navigation-critical pages
- Updated aiPlannerService to include duration in API requests
- Changed rounding logic from `int()` to `round()` for better scaling

### 📝 Documentation
- Updated main README with recent features
- Added comprehensive feature descriptions
- Documented AI planner setup and requirements
- Added Recent Updates section
- Created CHANGELOG.md for version tracking

### 🗃️ Backend Changes
- **Node.js Backend**
  - Added duration parameter to workout plan generation
  - Updated message builder to include workout duration
  - Exercise search endpoint improvements

- **Python AI API**
  - Enhanced predict_sets.py with duration-based scaling
  - Updated nl_parser.py to parse workout duration
  - Fixed expert_rules.py with round-robin distribution
  - Added Duration field to default profile

### 📱 Frontend Changes
- Added ExerciseDatabaseService for GIF lookups
- Created ExerciseDetailsDialog widget
- Updated CreateWorkoutPlanPage with exercise click handlers
- Enhanced rest day display with spa icon
- Fixed navigation flow in Profile, Analytics, Features pages

## [1.0.0] - Initial Release

### Features
- User authentication (register/login/logout)
- Workout logging with exercises tracking
- Analytics dashboard with charts
- Achievement and rewards system
- Profile page with stats
- Streak tracking
- MongoDB backend with JWT authentication
- Flutter mobile app with Provider state management
