#!/usr/bin/env python3
"""
Enhanced Rep Counter with Clear Visual Feedback for xiA6lRr
"""

import cv2
import mediapipe as mp
import numpy as np
import json
import time
from collections import deque

class EnhancedRepCounter:
    def __init__(self, exercise_id="xiA6lRr"):
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
        self.current_exercise_id = exercise_id
        self.current_exercise_name = self.exercise_mapping[self.current_exercise_id]
        
        # Rep counting with enhanced tracking
        self.angle_buffer = deque(maxlen=30)
        self.phase_buffer = deque(maxlen=5)
        self.rep_count = 0
        self.current_phase = "start"
        self.last_rep_time = 0
        self.phase_history = deque(maxlen=10)
        
        # Enhanced visual feedback
        self.rep_flash_timer = 0
        self.rep_flash_duration = 2.0  # 2 seconds of celebration
        self.last_rep_angles = []
        self.rep_quality_scores = []
        
        print(f"🎯 Enhanced Rep Counter: {self.current_exercise_id} - {self.current_exercise_name}")
        print("💡 Look for BRIGHT rep counting feedback on screen!")
        
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
            
            return angles, points
            
        except Exception as e:
            return None, {}
    
    def enhanced_rep_detection(self, angles):
        """Enhanced rep counting with better validation"""
        if not angles:
            return
        
        # For bicep curls, focus on elbow angles
        left_elbow = angles['left_elbow']
        right_elbow = angles['right_elbow']
        primary_angle = min(left_elbow, right_elbow)  # Use the more bent elbow
        
        # Add to buffer
        self.angle_buffer.append(primary_angle)
        
        if len(self.angle_buffer) < 15:
            return
        
        # Get recent angle history
        recent_angles = list(self.angle_buffer)[-15:]
        angle_range = max(recent_angles) - min(recent_angles)
        current_velocity = abs(recent_angles[-1] - recent_angles[-5]) if len(recent_angles) >= 5 else 0
        
        # Enhanced phase detection for bicep curls
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
        
        # Phase validation with consensus
        self.phase_buffer.append(new_phase)
        if len(self.phase_buffer) >= 3:
            most_common = max(set(self.phase_buffer), key=list(self.phase_buffer).count)
            if most_common != self.current_phase:
                self.current_phase = most_common
                self.phase_history.append(most_common)
                print(f"🔄 Phase: {most_common.upper()} (Angle: {primary_angle:.1f}°)")
        
        # Enhanced rep detection
        timestamp = time.time()
        is_good_rep = (
            self.current_phase == "start" and 
            timestamp - self.last_rep_time > 1.5 and  # Minimum 1.5 seconds between reps
            angle_range > 70 and  # Good range of motion (70+ degrees)
            len([p for p in self.phase_history if p in ["peak", "return"]]) >= 1  # Must have gone through peak
        )
        
        if is_good_rep:
            self.rep_count += 1
            self.last_rep_time = timestamp
            self.rep_flash_timer = timestamp
            self.last_rep_angles = recent_angles.copy()
            
            # Calculate rep quality
            quality = min(100, (angle_range - 70) / 60 * 100)  # Scale to 0-100
            self.rep_quality_scores.append(quality)
            
            print(f"🎯 REP {self.rep_count} COMPLETED! (Range: {angle_range:.1f}°, Quality: {quality:.0f}%)")
            
            # Clear phase history for next rep
            self.phase_history.clear()
    
    def draw_enhanced_feedback(self, frame, angles, points):
        """Draw enhanced visual feedback with rep celebration"""
        h, w = frame.shape[:2]
        timestamp = time.time()
        
        # Main info panel with larger font
        info_bg_height = 280
        cv2.rectangle(frame, (10, 10), (450, info_bg_height), (0, 0, 0), -1)
        cv2.rectangle(frame, (10, 10), (450, info_bg_height), (0, 255, 0), 3)
        
        # Exercise info
        cv2.putText(frame, f"Exercise: {self.current_exercise_name}", (20, 40), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
        
        # HUGE rep counter
        rep_color = (0, 255, 255)
        cv2.putText(frame, f"REPS: {self.rep_count}", (20, 80), 
                   cv2.FONT_HERSHEY_SIMPLEX, 1.2, rep_color, 3)
        
        # Current phase with color coding
        phase_colors = {
            "start": (0, 255, 0),     # Green
            "quarter": (0, 255, 255),  # Yellow
            "peak": (0, 0, 255),      # Red
            "return": (255, 0, 255),   # Magenta
            "end": (255, 255, 0)      # Cyan
        }
        phase_color = phase_colors.get(self.current_phase, (128, 128, 128))
        cv2.putText(frame, f"Phase: {self.current_phase.upper()}", (20, 120), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.8, phase_color, 2)
        
        # Angle information
        if angles:
            cv2.putText(frame, f"L Elbow: {angles['left_elbow']:.1f}°", (20, 160), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
            cv2.putText(frame, f"R Elbow: {angles['right_elbow']:.1f}°", (20, 190), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
            
            # Range of motion indicator
            if len(self.angle_buffer) >= 10:
                recent = list(self.angle_buffer)[-10:]
                current_range = max(recent) - min(recent)
                range_color = (0, 255, 0) if current_range > 70 else (0, 165, 255)
                cv2.putText(frame, f"Range: {current_range:.1f}° ({'GOOD' if current_range > 70 else 'MORE'})", 
                           (20, 220), cv2.FONT_HERSHEY_SIMPLEX, 0.6, range_color, 2)
        
        # Average quality
        if self.rep_quality_scores:
            avg_quality = np.mean(self.rep_quality_scores)
            quality_color = (0, 255, 0) if avg_quality > 70 else (0, 165, 255)
            cv2.putText(frame, f"Avg Quality: {avg_quality:.0f}%", (20, 250), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.6, quality_color, 2)
        
        # REP CELEBRATION FLASH! 
        if timestamp - self.rep_flash_timer < self.rep_flash_duration:
            flash_intensity = 1.0 - (timestamp - self.rep_flash_timer) / self.rep_flash_duration
            
            # Massive celebration text
            celebration_size = int(100 * flash_intensity)
            if celebration_size > 20:
                cv2.putText(frame, f"REP {self.rep_count}!", (w//2 - 150, h//2), 
                           cv2.FONT_HERSHEY_SIMPLEX, 2.0 * flash_intensity, (0, 255, 0), 
                           int(5 * flash_intensity))
                
                # Flash border
                if flash_intensity > 0.5:
                    cv2.rectangle(frame, (0, 0), (w, h), (0, 255, 0), int(10 * flash_intensity))
        
        # Phase indicator circle
        phase_center = (w - 80, 80)
        cv2.circle(frame, phase_center, 40, phase_color, -1)
        cv2.circle(frame, phase_center, 40, (255, 255, 255), 3)
        cv2.putText(frame, self.current_phase[:4].upper(), (w - 100, 85), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
        
        # Progress bar for current rep
        if len(self.angle_buffer) >= 5:
            recent = list(self.angle_buffer)[-5:]
            current_angle = recent[-1]
            progress = max(0, min(1, (180 - current_angle) / 120))  # 0-1 based on curl progress
            
            bar_width = 300
            bar_x = (w - bar_width) // 2
            bar_y = h - 60
            
            # Background
            cv2.rectangle(frame, (bar_x, bar_y), (bar_x + bar_width, bar_y + 20), (50, 50, 50), -1)
            # Progress
            cv2.rectangle(frame, (bar_x, bar_y), (bar_x + int(bar_width * progress), bar_y + 20), 
                         (0, 255, 0), -1)
            # Border
            cv2.rectangle(frame, (bar_x, bar_y), (bar_x + bar_width, bar_y + 20), (255, 255, 255), 2)
            cv2.putText(frame, f"Rep Progress: {progress*100:.0f}%", (bar_x, bar_y - 10), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        
        # Instructions
        cv2.putText(frame, "Do slow bicep curls - watch for REP FLASH!", (20, h - 20), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)
    
    def process_frame(self, frame):
        """Process frame with enhanced feedback"""
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.pose.process(rgb_frame)
        
        if results.pose_landmarks:
            angles, points = self.extract_pose_features(results)
            if angles:
                self.enhanced_rep_detection(angles)
                
                # Draw pose
                self.mp_drawing.draw_landmarks(
                    frame, results.pose_landmarks, self.mp_pose.POSE_CONNECTIONS
                )
                
                # Draw enhanced feedback
                self.draw_enhanced_feedback(frame, angles, points)
        else:
            # No pose detected
            h, w = frame.shape[:2]
            cv2.putText(frame, "STEP INTO CAMERA VIEW", (w//4, h//2), 
                       cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 0, 255), 3)
        
        return frame

def main():
    print("🚀 Enhanced Rep Counter with CLEAR Visual Feedback")
    print("=" * 60)
    print(f"🎯 Exercise: xiA6lRr - dumbbell seated bicep curl")
    print("💡 Look for BRIGHT flashing REP notifications!")
    print("📊 Enhanced progress bars and quality feedback")
    print("🎮 Press 'q' to quit")
    print("=" * 60)
    
    counter = EnhancedRepCounter("xiA6lRr")
    
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    
    try:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            processed_frame = counter.process_frame(frame)
            cv2.imshow('Enhanced Rep Counter - xiA6lRr', processed_frame)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    
    except KeyboardInterrupt:
        print("\n⏹️ Stopping enhanced counter...")
    
    finally:
        cap.release()
        cv2.destroyAllWindows()
        
        print(f"\n🏁 Session Complete:")
        print(f"   Total Reps: {counter.rep_count}")
        if counter.rep_quality_scores:
            print(f"   Average Quality: {np.mean(counter.rep_quality_scores):.0f}%")
        print(f"   Exercise: {counter.current_exercise_name}")

if __name__ == "__main__":
    main()
