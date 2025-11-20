#!/usr/bin/env python3
"""
Debug Rep Counter for xiA6lRr issue
"""

import cv2
import mediapipe as mp
import numpy as np
import pandas as pd
import json
import time
from collections import deque

class DebugRepCounter:
    def __init__(self):
        # Initialize MediaPipe
        self.mp_pose = mp.solutions.pose
        self.mp_drawing = mp.solutions.drawing_utils
        self.pose = self.mp_pose.Pose(
            min_detection_confidence=0.8,
            min_tracking_confidence=0.8,
            model_complexity=2
        )
        
        # Load exercise data
        with open('data/corrected_exercise_mapping.json', 'r') as f:
            data = json.load(f)
        self.exercise_mapping = data['correct_mapping']
        
        # Set target exercise
        self.current_exercise_id = "xiA6lRr"
        self.current_exercise_name = self.exercise_mapping[self.current_exercise_id]
        
        # Rep counting
        self.angle_buffer = deque(maxlen=30)
        self.phase_buffer = deque(maxlen=5)
        self.rep_count = 0
        self.current_phase = "start"
        self.last_rep_time = 0
        self.debug_frames = 0
        
        print(f"🎯 Debug Mode: {self.current_exercise_id} - {self.current_exercise_name}")
        print("🔍 Will show detailed rep counting debug info")
        
    def calculate_angle(self, a, b, c):
        """Calculate angle with numerical stability"""
        try:
            a, b, c = np.array(a), np.array(b), np.array(c)
            radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
            angle = np.abs(radians * 180.0 / np.pi)
            return float(np.clip(360 - angle if angle > 180 else angle, 0, 180))
        except:
            return 90.0
    
    def extract_pose_features(self, results):
        """Extract pose features with debug info"""
        try:
            if not results.pose_landmarks:
                return None, {}
            
            landmarks = results.pose_landmarks.landmark
            
            # Key body landmarks
            points = {}
            landmark_names = [
                'LEFT_SHOULDER', 'RIGHT_SHOULDER', 'LEFT_ELBOW', 'RIGHT_ELBOW',
                'LEFT_WRIST', 'RIGHT_WRIST', 'LEFT_HIP', 'RIGHT_HIP'
            ]
            
            for name in landmark_names:
                landmark = landmarks[getattr(self.mp_pose.PoseLandmark, name)]
                points[name.lower()] = [landmark.x, landmark.y]
            
            # Calculate angles (focusing on bicep curl)
            angles = {
                'left_elbow': self.calculate_angle(
                    points['left_shoulder'], points['left_elbow'], points['left_wrist']
                ),
                'right_elbow': self.calculate_angle(
                    points['right_shoulder'], points['right_elbow'], points['right_wrist']
                ),
                'left_shoulder': self.calculate_angle(
                    points['left_hip'], points['left_shoulder'], points['left_elbow']
                ),
                'right_shoulder': self.calculate_angle(
                    points['right_hip'], points['right_shoulder'], points['right_elbow']
                ),
            }
            
            # Primary angles for bicep curl
            features = [
                angles['left_elbow'], angles['right_elbow'],
                angles['left_shoulder'], angles['right_shoulder'],
                90, 90, 90, 90  # Padding for consistency
            ]
            
            return features, angles
            
        except Exception as e:
            print(f"❌ Feature extraction error: {e}")
            return None, {}
    
    def debug_rep_detection(self, features, angles):
        """Debug rep counting with detailed output"""
        if not features:
            return
        
        self.debug_frames += 1
        
        # Add to buffer
        self.angle_buffer.append(features)
        
        if len(self.angle_buffer) < 10:
            return
        
        # For bicep curls, focus on elbow angles
        left_elbow = angles['left_elbow']
        right_elbow = angles['right_elbow']
        primary_angle = min(left_elbow, right_elbow)  # Use the more bent elbow
        
        # Get recent angle history
        recent_angles = [min(frame[0], frame[1]) for frame in list(self.angle_buffer)[-10:]]
        angle_range = max(recent_angles) - min(recent_angles)
        
        # Simple phase detection for bicep curls
        if primary_angle > 160:  # Arms extended
            new_phase = "start"
        elif primary_angle > 120:  # Quarter way
            new_phase = "quarter"
        elif primary_angle < 60:   # Peak contraction
            new_phase = "peak"
        elif primary_angle < 100:  # Returning
            new_phase = "return"
        else:  # Back to extended
            new_phase = "end"
        
        # Phase validation
        self.phase_buffer.append(new_phase)
        if len(self.phase_buffer) >= 3:
            most_common = max(set(self.phase_buffer), key=list(self.phase_buffer).count)
            if most_common != self.current_phase:
                print(f"🔄 Phase: {self.current_phase} → {most_common} (Angle: {primary_angle:.1f}°, Range: {angle_range:.1f}°)")
                self.current_phase = most_common
        
        # Rep detection (simple: peak → start transition with good range)
        timestamp = time.time()
        if (self.current_phase == "start" and 
            timestamp - self.last_rep_time > 1.0 and 
            angle_range > 60):  # Good range of motion
            
            self.rep_count += 1
            self.last_rep_time = timestamp
            print(f"🎯 REP {self.rep_count} DETECTED! (Range: {angle_range:.1f}°)")
        
        # Debug output every 30 frames
        if self.debug_frames % 30 == 0:
            print(f"📊 Debug Frame {self.debug_frames}:")
            print(f"   Left Elbow: {left_elbow:.1f}°, Right Elbow: {right_elbow:.1f}°")
            print(f"   Primary Angle: {primary_angle:.1f}°, Range: {angle_range:.1f}°")
            print(f"   Phase: {self.current_phase}, Reps: {self.rep_count}")
            print(f"   Recent Phases: {list(self.phase_buffer)}")
            print()
    
    def process_frame(self, frame):
        """Process frame with debug output"""
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.pose.process(rgb_frame)
        
        if results.pose_landmarks:
            features, angles = self.extract_pose_features(results)
            if features:
                self.debug_rep_detection(features, angles)
                
                # Draw pose
                self.mp_drawing.draw_landmarks(
                    frame, results.pose_landmarks, self.mp_pose.POSE_CONNECTIONS
                )
                
                # Draw debug info
                h, w = frame.shape[:2]
                info = [
                    f"Exercise: {self.current_exercise_name}",
                    f"Reps: {self.rep_count}",
                    f"Phase: {self.current_phase}",
                    f"L Elbow: {angles['left_elbow']:.1f}°",
                    f"R Elbow: {angles['right_elbow']:.1f}°",
                    f"Debug Frame: {self.debug_frames}"
                ]
                
                # Background
                cv2.rectangle(frame, (10, 10), (300, 200), (0, 0, 0), -1)
                cv2.rectangle(frame, (10, 10), (300, 200), (0, 255, 0), 2)
                
                for i, text in enumerate(info):
                    y = 35 + i * 25
                    cv2.putText(frame, text, (20, y), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
                    
                # Instructions
                cv2.putText(frame, "Do bicep curls - watch terminal for debug info", 
                           (20, h - 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)
        else:
            # No pose detected
            cv2.putText(frame, "No pose detected - move into camera view", 
                       (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
        
        return frame

def main():
    print("🚀 Debug Rep Counter for xiA6lRr (Dumbbell Seated Bicep Curl)")
    print("=" * 60)
    print("📹 Starting camera debug session...")
    print("💡 Do slow bicep curls to test rep detection")
    print("🔍 Watch terminal for detailed debug output")
    print("🎮 Press 'q' to quit")
    print("=" * 60)
    
    debug_counter = DebugRepCounter()
    
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    
    try:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            processed_frame = debug_counter.process_frame(frame)
            cv2.imshow('Debug Rep Counter - xiA6lRr', processed_frame)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    
    except KeyboardInterrupt:
        print("\n⏹️ Stopping debug session...")
    
    finally:
        cap.release()
        cv2.destroyAllWindows()
        
        print(f"\n🏁 Debug Session Complete:")
        print(f"   Total Reps Detected: {debug_counter.rep_count}")
        print(f"   Frames Processed: {debug_counter.debug_frames}")
        print(f"   Final Phase: {debug_counter.current_phase}")

if __name__ == "__main__":
    main()
