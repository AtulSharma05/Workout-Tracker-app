# Pose Corrector Integration Plan

## 🎯 Overview
Integrating the AI Pose Corrector & Rep Counter system with the Workout Tracker App to provide real-time exercise form analysis and automatic rep counting during workout sessions.

## 📋 System Analysis

### Current Pose Corrector Capabilities
✅ **1,451 Exercise Patterns** - Comprehensive exercise database with angle measurements
✅ **LSTM Rep Counting** - Advanced AI-based phase detection (start → quarter → peak → return → end)
✅ **Real-time Form Analysis** - Exercise-specific corrections and feedback
✅ **MediaPipe Pose Detection** - Professional pose estimation with 33 body landmarks
✅ **90%+ Accuracy** - High-precision rep counting and form analysis
✅ **Exercise ID Targeting** - Specific exercise analysis with pattern matching

### Technical Requirements
- **Python 3.10** (MediaPipe doesn't support 3.13 yet)
- **Dependencies**: opencv-python, mediapipe, numpy, pandas, torch, scikit-learn
- **Hardware**: Camera/Webcam for video input
- **Processing**: Real-time 25-30 FPS analysis

## ✅ Python Version Isolation Strategy

**No Conflicts Between Services**:
- **AI Planner** (Port 8000): Uses system Python (3.13 works fine, doesn't need MediaPipe)
- **Pose Corrector** (Port 8001): Uses Python 3.10 in isolated virtual environment (`venv-py310`)
- **How it Works**: Windows Python Launcher (`py`) lets you run specific versions
- **Command Examples**:
  ```powershell
  python api_server.py          # Uses default Python (3.13) for AI Planner
  py -3.10 -m venv venv-py310   # Creates Python 3.10 environment for Pose Corrector
  ```

**Why This Works**:
1. Each service runs in its own process with its own dependencies
2. Virtual environments completely isolate package installations
3. Ports are different (8000 vs 8001) - no conflicts
4. Python installations are separate directories
5. No shared dependencies between the two services

## 🔧 Integration Strategy

### Phase 1: Environment Setup ⚠️ (BLOCKED)

**Option A: Install Python 3.10** (Recommended)
```powershell
# Download Python 3.10 from python.org
# Install alongside Python 3.13
# Create virtual environment
py -3.10 -m venv venv-py310

# Activate
.\venv-py310\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt
```

**Option B: Use Docker** (Alternative)
```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "professional_pose_corrector.py"]
```

**Option C: Use Conda** (Alternative)
```bash
conda create -n pose-corrector python=3.10
conda activate pose-corrector
pip install -r requirements.txt
```

### Phase 2: Test Standalone System

1. **Verify Installation**:
   ```python
   python professional_pose_corrector.py
   ```

2. **Test with Sample Exercise**:
   - Enter exercise ID (e.g., `0br45wL` for bicep curl)
   - Perform exercise in front of camera
   - Verify rep counting and form feedback

3. **Test Exercises from Workout Database**:
   - Map exercise names to exercise IDs
   - Test common exercises: bench press, squat, bicep curl, etc.

### Phase 3: Create REST API Wrapper

Create **`pose_corrector_api.py`** with FastAPI:

```python
from fastapi import FastAPI, WebSocket
import cv2
import base64
from professional_pose_corrector import ProfessionalPoseCorrector

app = FastAPI()
corrector = ProfessionalPoseCorrector()

@app.websocket("/ws/pose-analysis")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    while True:
        # Receive frame from client
        data = await websocket.receive_text()
        frame = base64_to_cv2(data)
        
        # Process frame
        results = corrector.analyze_frame(frame)
        
        # Send results back
        await websocket.send_json(results)

@app.post("/api/start-exercise")
async def start_exercise(exercise_id: str):
    corrector.set_exercise(exercise_id)
    return {"status": "started", "exercise_id": exercise_id}

@app.get("/api/session-summary")
async def get_summary():
    return corrector.get_session_summary()
```

### Phase 4: Backend Integration

**Add to Node.js Backend** (`backend/src/services/poseAnalysisService.js`):

```javascript
const WebSocket = require('ws');

class PoseAnalysisService {
  constructor() {
    this.poseApiUrl = 'ws://localhost:8001/ws/pose-analysis';
    this.ws = null;
  }

  async startSession(exerciseId) {
    // Start pose analysis session
    const response = await fetch('http://localhost:8001/api/start-exercise', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ exercise_id: exerciseId })
    });
    return response.json();
  }

  connectWebSocket(onMessage) {
    this.ws = new WebSocket(this.poseApiUrl);
    this.ws.on('message', onMessage);
  }

  sendFrame(frameBase64) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(frameBase64);
    }
  }

  async getSessionSummary() {
    const response = await fetch('http://localhost:8001/api/session-summary');
    return response.json();
  }
}

module.exports = new PoseAnalysisService();
```

### Phase 5: Frontend Integration (Flutter)

**Add Camera Package**:
```yaml
# pubspec.yaml
dependencies:
  camera: ^0.10.5
  web_socket_channel: ^2.4.0
```

**Create Pose Analysis Page** (`lib/pages/pose_analysis_page.dart`):

```dart
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PoseAnalysisPage extends StatefulWidget {
  final String exerciseName;
  final String exerciseId;
  
  @override
  _PoseAnalysisPageState createState() => _PoseAnalysisPageState();
}

class _PoseAnalysisPageState extends State<PoseAnalysisPage> {
  CameraController? _cameraController;
  WebSocketChannel? _channel;
  int _repCount = 0;
  String _currentPhase = 'start';
  List<String> _formFeedback = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _connectWebSocket();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    
    // Start streaming frames
    _cameraController!.startImageStream((image) {
      _sendFrameToServer(image);
    });
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://YOUR_IP:8001/ws/pose-analysis'),
    );
    
    _channel!.stream.listen((message) {
      final data = json.decode(message);
      setState(() {
        _repCount = data['rep_count'];
        _currentPhase = data['current_phase'];
        _formFeedback = List<String>.from(data['corrections']);
      });
    });
  }

  void _sendFrameToServer(CameraImage image) {
    // Convert to base64 and send
    final bytes = convertImageToBytes(image);
    final base64Frame = base64Encode(bytes);
    _channel?.sink.add(base64Frame);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: Column(
        children: [
          // Camera preview
          Expanded(
            child: _cameraController?.value.isInitialized == true
                ? CameraPreview(_cameraController!)
                : CircularProgressIndicator(),
          ),
          
          // Rep counter
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Reps: $_repCount',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                Text('Phase: $_currentPhase'),
                SizedBox(height: 20),
                
                // Form feedback
                ..._formFeedback.map((feedback) => 
                  Text(feedback, style: TextStyle(color: Colors.orange))
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Phase 6: Exercise ID Mapping

**Create mapping file** (`backend/pose-corrector/data/exercise_id_mapping.json`):

```json
{
  "bench press": "3TZduzM",
  "barbell squat": "gf3ZjB9",
  "bicep curl": "0br45wL",
  "dumbbell shoulder press": "j6uIfep",
  "deadlift": "27NNGFr",
  ...
}
```

**Backend Service**:
```javascript
// backend/src/services/exerciseMappingService.js
const exerciseMapping = require('../pose-corrector/data/exercise_id_mapping.json');

class ExerciseMappingService {
  getExerciseId(exerciseName) {
    const normalized = exerciseName.toLowerCase().trim();
    return exerciseMapping[normalized] || null;
  }
  
  getAllMappedExercises() {
    return Object.keys(exerciseMapping);
  }
}
```

## 📊 Data Flow

```
Flutter App (Camera)
    ↓ (WebSocket - Video Frames)
Node.js Backend (Proxy)
    ↓ (WebSocket Forward)
Python Pose API (Port 8001)
    ↓ (MediaPipe + LSTM Processing)
    ↑ (Rep Count + Form Analysis)
Node.js Backend
    ↑ (WebSocket Response)
Flutter App (UI Update)
```

## 🎯 Integration Points

1. **Start Workout Session**:
   - User selects exercise from workout plan
   - Backend maps exercise name → exercise ID
   - Start pose analysis session
   - Open camera in Flutter

2. **During Workout**:
   - Stream camera frames (30 FPS)
   - Receive rep counts in real-time
   - Display form corrections
   - Update UI with current phase

3. **End Workout Session**:
   - Get session summary (total reps, form score, quality metrics)
   - Save to workout history
   - Display achievements if unlocked

## ⚙️ Configuration

**Environment Variables**:
```env
# .env
POSE_API_URL=http://localhost:8001
POSE_WEBSOCKET_URL=ws://localhost:8001/ws/pose-analysis
```

**Backend Config** (`backend/config/pose.config.js`):
```javascript
module.exports = {
  poseApi: {
    url: process.env.POSE_API_URL || 'http://localhost:8001',
    wsUrl: process.env.POSE_WEBSOCKET_URL || 'ws://localhost:8001/ws/pose-analysis',
    timeout: 30000,
    reconnectAttempts: 3
  }
};
```

## 🚀 Deployment Considerations

1. **Python Service**:
   - Run as separate microservice
   - Use supervisor/systemd for process management
   - Scale horizontally for multiple users

2. **Resource Requirements**:
   - CPU: 2-4 cores recommended
   - RAM: 2GB minimum for PyTorch models
   - GPU: Optional but improves performance

3. **Performance Optimization**:
   - Frame rate throttling (15 FPS instead of 30)
   - Model quantization for mobile deployment
   - Edge processing on device (TensorFlow Lite)

## 📝 Testing Plan

1. **Unit Tests**:
   - Test exercise ID mapping
   - Test WebSocket connection
   - Test rep counting accuracy

2. **Integration Tests**:
   - End-to-end workout session
   - Camera stream handling
   - Real-time updates

3. **Performance Tests**:
   - Latency measurements
   - Frame processing speed
   - Memory usage

4. **User Acceptance Tests**:
   - Test with real users
   - Different exercise types
   - Various lighting conditions

## 🔐 Security Considerations

1. **Camera Permissions**: Request and handle properly in Flutter
2. **Data Privacy**: Video frames not stored (processed in memory)
3. **API Authentication**: Add JWT to WebSocket connections
4. **Rate Limiting**: Prevent abuse of pose analysis API

## 📚 Next Steps

1. ⚠️ **Install Python 3.10** (Blocker)
2. Test standalone pose corrector
3. Create FastAPI wrapper
4. Integrate with Node.js backend
5. Build Flutter camera interface
6. Create exercise ID mapping
7. End-to-end testing
8. Documentation and deployment

## 🎓 Resources

- **MediaPipe Pose**: https://google.github.io/mediapipe/solutions/pose
- **FastAPI WebSockets**: https://fastapi.tiangolo.com/advanced/websockets/
- **Flutter Camera**: https://pub.dev/packages/camera
- **PyTorch Mobile**: https://pytorch.org/mobile/

---

**Status**: ⚠️ Waiting for Python 3.10 environment setup
**Next Action**: Install Python 3.10 or set up alternative environment
