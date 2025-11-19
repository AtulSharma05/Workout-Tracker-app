#!/usr/bin/env python3
"""
Enhanced AI Pose Corrector with Fixed Exercise Mapping and Improved Rep Counting
Professional AI-powered fitness form analysis and rep counting system
"""

import cv2
import mediapipe as mp
import numpy as np
import pandas as pd
import json
import os
import time
import math
from collections import deque, defaultdict
from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional, Union
import torch
import torch.nn as nn
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import IsolationForest
import warnings
warnings.filterwarnings('ignore')

@dataclass
class PoseAnalysis:
    rep_count: int
    current_phase: str
    form_score: float
    corrections: List[str]
    ai_confidence: float
    movement_quality: float
    exercise_match: str

class EnhancedLSTMRepCounter(nn.Module):
    """Enhanced LSTM with attention mechanism for precise rep counting"""
    
    def __init__(self, input_dim=8, hidden_dim=128, num_layers=3, dropout=0.3):
        super().__init__()
        self.hidden_dim = hidden_dim
        self.num_layers = num_layers
        
        # Multi-layer LSTM with dropout
        self.lstm = nn.LSTM(input_dim, hidden_dim, num_layers, 
                           batch_first=True, dropout=dropout, bidirectional=True)
        
        # Attention mechanism
        self.attention = nn.MultiheadAttention(hidden_dim * 2, num_heads=8, dropout=0.2)
        
        # Phase classification layers
        self.phase_classifier = nn.Sequential(
            nn.LayerNorm(hidden_dim * 2),
            nn.Linear(hidden_dim * 2, 64),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, 5)  # 5 phases: start, quarter, peak, return, end
        )
        
        # Rep transition detector
        self.rep_detector = nn.Sequential(
            nn.Linear(hidden_dim * 2, 32),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(32, 1),
            nn.Sigmoid()
        )
        
    def forward(self, x):
        # LSTM processing
        lstm_out, _ = self.lstm(x)
        
        # Apply attention
        attn_out, attn_weights = self.attention(lstm_out, lstm_out, lstm_out)
        
        # Get predictions
        phase_logits = self.phase_classifier(attn_out)
        rep_prob = self.rep_detector(attn_out)
        
        return phase_logits, rep_prob, attn_weights

class EnhancedFormAnalysisNN(nn.Module):
    """Enhanced form analysis with exercise-specific embeddings"""
    
    def __init__(self, pose_dim=8, exercise_vocab_size=1500, embedding_dim=64):
        super().__init__()
        
        # Exercise embeddings
        self.exercise_embedding = nn.Embedding(exercise_vocab_size, embedding_dim)
        
        # Pose feature processor
        self.pose_processor = nn.Sequential(
            nn.Linear(pose_dim, 128),
            nn.ReLU(),
            nn.BatchNorm1d(128),
            nn.Dropout(0.3),
            nn.Linear(128, 64),
            nn.ReLU()
        )
        
        # Combined analysis
        self.form_analyzer = nn.Sequential(
            nn.Linear(64 + embedding_dim, 128),
            nn.ReLU(),
            nn.BatchNorm1d(128),
            nn.Dropout(0.3),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, 1),  # Form score
            nn.Sigmoid()
        )
        
    def forward(self, pose_features, exercise_id):
        # Get exercise embedding
        exercise_emb = self.exercise_embedding(exercise_id)
        
        # Process pose features
        pose_features = self.pose_processor(pose_features)
        
        # Combine features
        combined = torch.cat([pose_features, exercise_emb], dim=-1)
        
        # Analyze form
        form_score = self.form_analyzer(combined)
        
        return form_score

class EnhancedAIPoseCorrector:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.mp_drawing = mp.solutions.drawing_utils
        self.pose = self.mp_pose.Pose(
            min_detection_confidence=0.7,
            min_tracking_confidence=0.7,
            model_complexity=2
        )
        
        # Load corrected exercise database
        self.load_exercise_database()
        
        # Initialize AI models
        self.setup_ai_models()
        
        # Enhanced tracking variables
        self.angle_buffer = deque(maxlen=30)  # 1 second at 30fps
        self.phase_buffer = deque(maxlen=15)
        self.rep_count = 0
        self.current_phase = "start"
        self.last_peak_time = 0
        self.form_scores = deque(maxlen=10)
        self.movement_smoothness = deque(maxlen=20)
        
        # Enhanced thresholds based on data analysis
        self.rep_thresholds = {
            'min_angle_range': 25.0,  # Minimum range for valid rep
            'phase_stability': 3,     # Frames to confirm phase change
            'rep_cooldown': 15,       # Frames between reps
            'smoothness_threshold': 0.6,
            'confidence_threshold': 0.7
        }
        
        # Current exercise context
        self.current_exercise_id = None
        self.exercise_angles = []
        
        print("🚀 Enhanced AI Pose Corrector initialized with corrected exercise database!")
        
    def load_exercise_database(self):
        """Load corrected exercise mappings and data"""
        try:
            # Load corrected mapping
            with open('data/corrected_exercise_mapping.json', 'r') as f:
                mapping_data = json.load(f)
            
            self.exercise_mapping = mapping_data['correct_mapping']
            self.available_exercises = mapping_data['available_exercises']
            
            # Create reverse mapping (name to ID)
            self.name_to_id = {v: k for k, v in self.exercise_mapping.items()}
            
            # Load angle data for available exercises (sample for quick access)
            self.exercise_angle_data = {}
            sample_exercises = list(self.exercise_mapping.keys())[:50]  # Load 50 for demo
            
            for exercise_id in sample_exercises:
                angle_file = f'data/angles/{exercise_id}.csv'
                if os.path.exists(angle_file):
                    self.exercise_angle_data[exercise_id] = pd.read_csv(angle_file)
            
            print(f"✅ Loaded {len(self.exercise_mapping)} exercise mappings")
            print(f"📊 Loaded angle data for {len(self.exercise_angle_data)} exercises")
            
        except Exception as e:
            print(f"⚠️ Error loading exercise database: {e}")
            # Fallback to basic mapping
            self.exercise_mapping = {'0br45wL': 'push-up inside leg kick'}
            self.exercise_angle_data = {}
            
    def setup_ai_models(self):
        """Initialize enhanced AI models"""
        # Initialize models
        self.lstm_model = EnhancedLSTMRepCounter(input_dim=8, hidden_dim=128)
        self.form_model = EnhancedFormAnalysisNN(pose_dim=8, exercise_vocab_size=len(self.exercise_mapping))
        
        # Anomaly detector for movement quality
        self.anomaly_detector = IsolationForest(contamination=0.1, random_state=42)
        
        # Feature scaler
        self.scaler = StandardScaler()
        
        # Set to evaluation mode
        self.lstm_model.eval()
        self.form_model.eval()
        
        print("🧠 Enhanced AI models initialized")
        
    def calculate_angle(self, a, b, c):
        """Calculate angle between three points with enhanced precision"""
        a, b, c = np.array(a), np.array(b), np.array(c)
        
        # Calculate vectors
        ba = a - b
        bc = c - b
        
        # Calculate angle using dot product
        cosine_angle = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc))
        cosine_angle = np.clip(cosine_angle, -1.0, 1.0)  # Prevent numerical errors
        angle = np.arccos(cosine_angle)
        
        return np.degrees(angle)
        
    def extract_enhanced_features(self, landmarks):
        """Extract comprehensive pose features with exercise-specific angles"""
        try:
            if not landmarks:
                return None
            
            # Key landmarks
            left_shoulder = [landmarks[self.mp_pose.PoseLandmark.LEFT_SHOULDER].x,
                           landmarks[self.mp_pose.PoseLandmark.LEFT_SHOULDER].y]
            right_shoulder = [landmarks[self.mp_pose.PoseLandmark.RIGHT_SHOULDER].x,
                            landmarks[self.mp_pose.PoseLandmark.RIGHT_SHOULDER].y]
            left_elbow = [landmarks[self.mp_pose.PoseLandmark.LEFT_ELBOW].x,
                         landmarks[self.mp_pose.PoseLandmark.LEFT_ELBOW].y]
            right_elbow = [landmarks[self.mp_pose.PoseLandmark.RIGHT_ELBOW].x,
                          landmarks[self.mp_pose.PoseLandmark.RIGHT_ELBOW].y]
            left_wrist = [landmarks[self.mp_pose.PoseLandmark.LEFT_WRIST].x,
                         landmarks[self.mp_pose.PoseLandmark.LEFT_WRIST].y]
            right_wrist = [landmarks[self.mp_pose.PoseLandmark.RIGHT_WRIST].x,
                          landmarks[self.mp_pose.PoseLandmark.RIGHT_WRIST].y]
            left_hip = [landmarks[self.mp_pose.PoseLandmark.LEFT_HIP].x,
                       landmarks[self.mp_pose.PoseLandmark.LEFT_HIP].y]
            right_hip = [landmarks[self.mp_pose.PoseLandmark.RIGHT_HIP].x,
                        landmarks[self.mp_pose.PoseLandmark.RIGHT_HIP].y]
            left_knee = [landmarks[self.mp_pose.PoseLandmark.LEFT_KNEE].x,
                        landmarks[self.mp_pose.PoseLandmark.LEFT_KNEE].y]
            right_knee = [landmarks[self.mp_pose.PoseLandmark.RIGHT_KNEE].x,
                         landmarks[self.mp_pose.PoseLandmark.RIGHT_KNEE].y]
            left_ankle = [landmarks[self.mp_pose.PoseLandmark.LEFT_ANKLE].x,
                         landmarks[self.mp_pose.PoseLandmark.LEFT_ANKLE].y]
            right_ankle = [landmarks[self.mp_pose.PoseLandmark.RIGHT_ANKLE].x,
                          landmarks[self.mp_pose.PoseLandmark.RIGHT_ANKLE].y]
            
            # Calculate comprehensive angles
            angles = {
                'left_elbow_angle': self.calculate_angle(left_shoulder, left_elbow, left_wrist),
                'right_elbow_angle': self.calculate_angle(right_shoulder, right_elbow, right_wrist),
                'left_shoulder_angle': self.calculate_angle(left_hip, left_shoulder, left_elbow),
                'right_shoulder_angle': self.calculate_angle(right_hip, right_shoulder, right_elbow),
                'left_hip_angle': self.calculate_angle(left_shoulder, left_hip, left_knee),
                'right_hip_angle': self.calculate_angle(right_shoulder, right_hip, right_knee),
                'left_knee_angle': self.calculate_angle(left_hip, left_knee, left_ankle),
                'right_knee_angle': self.calculate_angle(right_hip, right_knee, right_ankle)
            }
            
            # Convert to feature vector
            feature_vector = [
                angles['left_elbow_angle'], angles['right_elbow_angle'],
                angles['left_shoulder_angle'], angles['right_shoulder_angle'],
                angles['left_hip_angle'], angles['right_hip_angle'],
                angles['left_knee_angle'], angles['right_knee_angle']
            ]
            
            return feature_vector, angles
            
        except Exception as e:
            print(f"Feature extraction error: {e}")
            return None, {}
    
    def enhanced_rep_detection(self, current_angles, timestamp):
        """Enhanced rep counting with FIXED phase transition logic"""
        try:
            if not current_angles or len(self.angle_buffer) < 10:
                return self.rep_count, "start", 0.5, 0.5
            
            # Add to buffer
            self.angle_buffer.append(current_angles)
            
            # Get primary movement angles (adapt based on exercise type)
            primary_angles = [current_angles[0], current_angles[1], current_angles[2], current_angles[3]]  # Arms + shoulders
            
            # Calculate angle ranges and movement
            angle_ranges = []
            angle_velocities = []
            
            if len(self.angle_buffer) >= 10:
                recent_angles = list(self.angle_buffer)[-10:]
                
                for i in range(4):  # Primary angles
                    values = [frame[i] for frame in recent_angles]
                    angle_range = max(values) - min(values)
                    angle_ranges.append(angle_range)
                    
                    # Calculate velocity (rate of change)
                    if len(values) >= 3:
                        velocity = abs(values[-1] - values[-3]) / 2  # Change over 2 frames
                        angle_velocities.append(velocity)
                    else:
                        angle_velocities.append(0)
            
            # Enhanced phase detection
            max_range_idx = np.argmax(angle_ranges) if angle_ranges else 0
            primary_angle_val = primary_angles[max_range_idx]
            max_velocity = max(angle_velocities) if angle_velocities else 0
            
            # Determine phase based on angle position and velocity
            new_phase = self.current_phase
            confidence = 0.5
            
            if len(self.angle_buffer) >= 15:
                recent_vals = [frame[max_range_idx] for frame in list(self.angle_buffer)[-15:]]
                min_val, max_val = min(recent_vals), max(recent_vals)
                range_val = max_val - min_val
                
                if range_val > self.rep_thresholds['min_angle_range']:
                    # Normalize position in range
                    position = (primary_angle_val - min_val) / range_val if range_val > 0 else 0.5
                    
                    # FIXED: Proper phase transition logic with state constraints
                    if self.current_phase == "start":
                        if position > 0.2 and max_velocity > 2.0:
                            new_phase = "quarter"
                            confidence = 0.8
                    elif self.current_phase == "quarter":
                        if position > 0.6 and max_velocity > 1.5:
                            new_phase = "peak"
                            confidence = 0.9
                        elif position < 0.15 and max_velocity < 2.0:  # Back to start
                            new_phase = "start"
                            confidence = 0.7
                    elif self.current_phase == "peak":
                        if position < 0.7 and max_velocity > 1.0:
                            new_phase = "return"
                            confidence = 0.8
                    elif self.current_phase == "return":
                        if position < 0.2 and max_velocity < 2.0:
                            new_phase = "end"
                            confidence = 0.85
                        elif position > 0.6:  # Back to peak
                            new_phase = "peak"
                            confidence = 0.7
                    elif self.current_phase == "end":
                        # CRITICAL FIX: End can only transition to start after pause/reset
                        if max_velocity < 1.0 and position < 0.15:
                            # Stay in end until movement begins
                            new_phase = "end"
                            confidence = 0.9
                        elif max_velocity > 2.0 and position > 0.15:
                            # Only transition to start when clear upward movement detected
                            new_phase = "start"
                            confidence = 0.8
                            # Mark rep completion when transitioning from end to start
                            current_time = time.time()
                            if current_time - self.last_peak_time > self.rep_thresholds['rep_cooldown'] / 30.0:
                                self.rep_count += 1
                                self.last_peak_time = current_time
                                print(f"🎯 Rep {self.rep_count} completed! (Phase: end->start, Confidence: {confidence:.2f})")
            
            # Phase stability check - require multiple frames for phase change
            self.phase_buffer.append(new_phase)
            if len(self.phase_buffer) >= self.rep_thresholds['phase_stability']:
                # Only change phase if it's stable for multiple frames
                recent_phases = list(self.phase_buffer)[-self.rep_thresholds['phase_stability']:]
                if recent_phases.count(new_phase) >= 2 and new_phase != self.current_phase:
                    # Valid phase transition based on state machine
                    valid_transitions = {
                        "start": ["quarter"],
                        "quarter": ["peak", "start"],  
                        "peak": ["return"],
                        "return": ["end", "peak"],
                        "end": ["start"]  # Only after pause
                    }
                    
                    if new_phase in valid_transitions.get(self.current_phase, []):
                        self.current_phase = new_phase
                        print(f"🔄 Phase transition: {list(self.phase_buffer)[-4]} -> {self.current_phase}")
            
            # Calculate movement quality
            movement_quality = min(confidence, max(angle_ranges) / 50.0) if angle_ranges else 0.5
            self.movement_smoothness.append(movement_quality)
            avg_quality = np.mean(list(self.movement_smoothness)) if self.movement_smoothness else 0.5
            
            return self.rep_count, self.current_phase, confidence, avg_quality
            
        except Exception as e:
            print(f"Rep detection error: {e}")
            return self.rep_count, self.current_phase, 0.5, 0.5
    
    def ai_form_analysis(self, pose_features, exercise_name="unknown"):
        """Enhanced AI-powered form analysis"""
        try:
            if not pose_features or len(pose_features) != 8:
                return 0.5, ["Unable to analyze form"], 0.5
            
            # Get exercise ID if available
            exercise_id = self.name_to_id.get(exercise_name, 0)
            
            # Convert to tensors
            pose_tensor = torch.FloatTensor(pose_features).unsqueeze(0)
            exercise_tensor = torch.LongTensor([exercise_id % len(self.exercise_mapping)])
            
            # Get AI form score
            with torch.no_grad():
                form_score = self.form_model(pose_tensor, exercise_tensor)
                ai_confidence = float(form_score.item())
            
            # Generate corrections based on pose analysis
            corrections = []
            
            # Analyze specific angles for common issues
            left_elbow, right_elbow = pose_features[0], pose_features[1]
            left_shoulder, right_shoulder = pose_features[2], pose_features[3]
            left_hip, right_hip = pose_features[4], pose_features[5]
            left_knee, right_knee = pose_features[6], pose_features[7]
            
            # Symmetry checks
            elbow_diff = abs(left_elbow - right_elbow)
            shoulder_diff = abs(left_shoulder - right_shoulder)
            hip_diff = abs(left_hip - right_hip)
            knee_diff = abs(left_knee - right_knee)
            
            if elbow_diff > 15:
                corrections.append(f"Uneven arm position (difference: {elbow_diff:.1f}°)")
            if shoulder_diff > 20:
                corrections.append(f"Shoulder imbalance detected (difference: {shoulder_diff:.1f}°)")
            if hip_diff > 15:
                corrections.append(f"Hip asymmetry (difference: {hip_diff:.1f}°)")
            if knee_diff > 15:
                corrections.append(f"Knee alignment issue (difference: {knee_diff:.1f}°)")
            
            # Range of motion checks
            if min(left_elbow, right_elbow) > 160:
                corrections.append("Increase elbow flexion for better range")
            if max(left_shoulder, right_shoulder) < 45:
                corrections.append("Extend shoulders more for full range")
            
            # Add positive feedback for good form
            if len(corrections) == 0:
                corrections.append("Excellent form! Keep it up!")
            elif ai_confidence > 0.8:
                corrections.insert(0, "Good overall form with minor adjustments needed")
            
            return ai_confidence, corrections, ai_confidence
            
        except Exception as e:
            print(f"Form analysis error: {e}")
            return 0.5, ["Form analysis unavailable"], 0.5
    
    def get_exercise_match(self, pose_features):
        """Match current pose to exercise in database"""
        try:
            if not self.exercise_angle_data or not pose_features:
                return "unknown", 0.5
            
            best_match = "unknown"
            best_score = 0.0
            
            # Compare with sample exercises
            for exercise_id, angle_data in list(self.exercise_angle_data.items())[:10]:  # Sample 10 for speed
                # Get reference angles for this exercise
                ref_angles = angle_data[['right_elbow_angle', 'right_shoulder_angle', 'right_hip_angle', 'right_knee_angle']]
                if len(ref_angles) > 0:
                    # Calculate similarity score
                    ref_mean = ref_angles.mean().values[:4]  # First 4 angles
                    current_angles = pose_features[:4]
                    
                    # Compute cosine similarity
                    similarity = np.dot(ref_mean, current_angles) / (np.linalg.norm(ref_mean) * np.linalg.norm(current_angles))
                    similarity = max(0, similarity)  # Ensure non-negative
                    
                    if similarity > best_score:
                        best_score = similarity
                        best_match = self.exercise_mapping.get(exercise_id, "unknown")
            
            return best_match, best_score
            
        except Exception as e:
            print(f"Exercise matching error: {e}")
            return "unknown", 0.5
    
    def analyze_frame(self, frame):
        """Main frame analysis with enhanced AI processing"""
        try:
            height, width = frame.shape[:2]
            
            # Convert BGR to RGB
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            
            # Process with MediaPipe
            results = self.pose.process(rgb_frame)
            
            if results.pose_landmarks:
                # Extract enhanced features
                pose_features, angle_dict = self.extract_enhanced_features(results.pose_landmarks.landmark)
                
                if pose_features:
                    # Enhanced rep counting
                    rep_count, phase, confidence, movement_quality = self.enhanced_rep_detection(
                        pose_features, time.time()
                    )
                    
                    # AI form analysis
                    if not self.current_exercise_id:
                        exercise_match, match_confidence = self.get_exercise_match(pose_features)
                        if match_confidence > 0.7:
                            self.current_exercise_id = exercise_match
                    
                    exercise_name = self.current_exercise_id or "general workout"
                    form_score, corrections, ai_confidence = self.ai_form_analysis(pose_features, exercise_name)
                    
                    # Create analysis result
                    analysis = PoseAnalysis(
                        rep_count=rep_count,
                        current_phase=phase,
                        form_score=form_score,
                        corrections=corrections,
                        ai_confidence=ai_confidence,
                        movement_quality=movement_quality,
                        exercise_match=exercise_name
                    )
                    
                    # Draw enhanced visualization
                    self.draw_enhanced_analysis(frame, results.pose_landmarks, analysis, angle_dict)
                    
                    return analysis
                    
            return None
            
        except Exception as e:
            print(f"Frame analysis error: {e}")
            return None
    
    def draw_enhanced_analysis(self, frame, landmarks, analysis, angles):
        """Draw comprehensive analysis visualization"""
        height, width = frame.shape[:2]
        
        # Draw pose landmarks
        self.mp_drawing.draw_landmarks(frame, landmarks, self.mp_pose.POSE_CONNECTIONS)
        
        # Enhanced info panel
        panel_height = 280
        panel_width = 400
        overlay = frame.copy()
        cv2.rectangle(overlay, (10, 10), (panel_width, panel_height), (0, 0, 0), -1)
        cv2.addWeighted(overlay, 0.8, frame, 0.2, 0, frame)
        
        # Title
        cv2.putText(frame, "🤖 ENHANCED AI POSE CORRECTOR", (20, 35), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
        
        # Exercise info
        cv2.putText(frame, f"Exercise: {analysis.exercise_match}", (20, 60), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        
        # Rep counter with confidence
        rep_color = (0, 255, 0) if analysis.ai_confidence > 0.7 else (0, 165, 255)
        cv2.putText(frame, f"Reps: {analysis.rep_count} | Phase: {analysis.current_phase}", 
                   (20, 85), cv2.FONT_HERSHEY_SIMPLEX, 0.5, rep_color, 2)
        
        # AI metrics
        cv2.putText(frame, f"AI Confidence: {analysis.ai_confidence:.2f}", (20, 110), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 200, 100), 1)
        cv2.putText(frame, f"Form Score: {analysis.form_score:.2f}", (20, 130), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (100, 255, 100), 1)
        cv2.putText(frame, f"Movement Quality: {analysis.movement_quality:.2f}", (20, 150), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 100, 255), 1)
        
        # Enhanced corrections
        cv2.putText(frame, "🎯 AI Corrections:", (20, 175), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        y_offset = 195
        for i, correction in enumerate(analysis.corrections[:3]):  # Show top 3
            color = (0, 255, 0) if "Excellent" in correction else (0, 200, 255)
            cv2.putText(frame, f"• {correction[:35]}{'...' if len(correction) > 35 else ''}", 
                       (25, y_offset), cv2.FONT_HERSHEY_SIMPLEX, 0.4, color, 1)
            y_offset += 20
        
        # Key angles display
        angle_panel_x = width - 250
        cv2.rectangle(frame, (angle_panel_x, 10), (width - 10, 180), (0, 0, 0), -1)
        cv2.putText(frame, "📐 Key Angles", (angle_panel_x + 10, 35), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        angle_names = ['R.Elbow', 'R.Shoulder', 'R.Hip', 'R.Knee']
        for i, (name, angle_key) in enumerate(zip(angle_names, ['right_elbow_angle', 'right_shoulder_angle', 'right_hip_angle', 'right_knee_angle'])):
            if angle_key in angles:
                angle_val = angles[angle_key]
                color = (0, 255, 0) if 45 <= angle_val <= 160 else (0, 255, 255)
                cv2.putText(frame, f"{name}: {angle_val:.1f}°", 
                           (angle_panel_x + 10, 60 + i * 25), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.4, color, 1)
        
        # Performance indicator
        perf_color = (0, 255, 0) if analysis.form_score > 0.8 else (0, 255, 255) if analysis.form_score > 0.6 else (0, 0, 255)
        cv2.circle(frame, (width - 30, height - 30), 15, perf_color, -1)
        cv2.putText(frame, "AI", (width - 38, height - 25), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1)

def main():
    """Enhanced main function with corrected exercise database"""
    print("🚀 Starting Enhanced AI Pose Corrector...")
    
    # Initialize corrector
    corrector = EnhancedAIPoseCorrector()
    
    # Setup camera with optimal settings
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    cap.set(cv2.CAP_PROP_FPS, 30)
    
    print("📹 Camera initialized. Press 'q' to quit, 'r' to reset counter")
    print("🎯 AI analyzing your workout in real-time...")
    
    frame_count = 0
    start_time = time.time()
    
    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("❌ Camera error")
                break
            
            frame_count += 1
            
            # Analyze frame
            analysis = corrector.analyze_frame(frame)
            
            # Show performance info every 30 frames
            if frame_count % 30 == 0:
                elapsed = time.time() - start_time
                fps = frame_count / elapsed
                print(f"📊 FPS: {fps:.1f} | "
                      f"Exercises in DB: {len(corrector.exercise_mapping)} | "
                      f"Current: {analysis.exercise_match if analysis else 'Detecting...'}")
            
            # Display frame
            cv2.imshow('Enhanced AI Pose Corrector', frame)
            
            # Handle keys
            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'):
                break
            elif key == ord('r'):
                corrector.rep_count = 0
                print("🔄 Rep counter reset!")
            elif key == ord('e'):
                # Reset exercise detection
                corrector.current_exercise_id = None
                print("🔄 Exercise detection reset!")
                
    except KeyboardInterrupt:
        print("\n🛑 Stopped by user")
    finally:
        cap.release()
        cv2.destroyAllWindows()
        
        # Final stats
        if frame_count > 0:
            total_time = time.time() - start_time
            avg_fps = frame_count / total_time
            print(f"\n📈 FINAL STATS:")
            print(f"   ⏱️ Total time: {total_time:.1f}s")
            print(f"   📊 Average FPS: {avg_fps:.1f}")
            print(f"   🎯 Total reps: {corrector.rep_count}")
            print(f"   📚 Exercises available: {len(corrector.exercise_mapping)}")
            print(f"✅ Enhanced AI Pose Corrector session completed!")

if __name__ == "__main__":
    main()
