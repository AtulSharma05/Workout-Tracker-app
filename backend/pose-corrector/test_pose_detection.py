#!/usr/bin/env python3
"""
Standalone test script for MediaPipe pose detection
Tests with webcam to verify the model works before Flutter integration
"""

import cv2
import mediapipe as mp
import numpy as np

def test_mediapipe_webcam():
    """Test MediaPipe pose detection with webcam"""
    
    # Initialize MediaPipe Pose
    mp_pose = mp.solutions.pose
    mp_drawing = mp.solutions.drawing_utils
    
    # Test with different confidence levels
    confidence_levels = [0.3, 0.5, 0.7]
    
    for confidence in confidence_levels:
        print(f"\n{'='*60}")
        print(f"Testing with confidence threshold: {confidence}")
        print(f"{'='*60}")
        
        pose = mp_pose.Pose(
            min_detection_confidence=confidence,
            min_tracking_confidence=confidence,
            model_complexity=1
        )
        
        # Open webcam
        cap = cv2.VideoCapture(0)
        
        if not cap.isOpened():
            print("❌ Could not open webcam")
            return
        
        # Set resolution
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
        
        print(f"✅ Webcam opened")
        print(f"📹 Press 'q' to quit, 's' to save frame, SPACE to try next confidence level")
        
        frame_count = 0
        detected_count = 0
        
        while True:
            ret, frame = cap.read()
            if not ret:
                print("❌ Failed to read frame")
                break
            
            frame_count += 1
            
            # Convert BGR to RGB
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            
            # Process with MediaPipe
            results = pose.process(rgb_frame)
            
            # Draw landmarks if detected
            if results.pose_landmarks:
                detected_count += 1
                mp_drawing.draw_landmarks(
                    frame,
                    results.pose_landmarks,
                    mp_pose.POSE_CONNECTIONS,
                    mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                    mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2, circle_radius=2)
                )
                
                # Add text overlay
                cv2.putText(frame, f"✓ POSE DETECTED (confidence={confidence})", 
                           (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
                cv2.putText(frame, f"Landmarks: {len(results.pose_landmarks.landmark)}", 
                           (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            else:
                cv2.putText(frame, f"✗ NO POSE DETECTED (confidence={confidence})", 
                           (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
            
            # Show detection rate
            detection_rate = (detected_count / frame_count) * 100 if frame_count > 0 else 0
            cv2.putText(frame, f"Detection rate: {detection_rate:.1f}% ({detected_count}/{frame_count})", 
                       (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
            
            # Display frame
            cv2.imshow(f'MediaPipe Pose Test (confidence={confidence})', frame)
            
            # Handle key presses
            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'):
                print(f"\n📊 Final stats for confidence {confidence}:")
                print(f"   Total frames: {frame_count}")
                print(f"   Detected: {detected_count}")
                print(f"   Detection rate: {detection_rate:.1f}%")
                cap.release()
                cv2.destroyAllWindows()
                return
            elif key == ord('s'):
                filename = f'test_frame_conf_{confidence}.jpg'
                cv2.imwrite(filename, frame)
                print(f"💾 Saved frame to {filename}")
            elif key == ord(' '):
                print(f"\n📊 Stats for confidence {confidence}:")
                print(f"   Total frames: {frame_count}")
                print(f"   Detected: {detected_count}")
                print(f"   Detection rate: {detection_rate:.1f}%")
                break
        
        cap.release()
        cv2.destroyAllWindows()
        pose.close()


def test_with_image():
    """Test MediaPipe with a static test image"""
    
    print(f"\n{'='*60}")
    print("Testing with static image (if debug_frame.jpg exists)")
    print(f"{'='*60}")
    
    try:
        # Try to load the debug frame
        frame = cv2.imread('debug_frame.jpg')
        if frame is None:
            print("⚠️ debug_frame.jpg not found, skipping static image test")
            return
        
        print(f"✅ Loaded debug_frame.jpg: {frame.shape}")
        
        # Initialize MediaPipe
        mp_pose = mp.solutions.pose
        mp_drawing = mp.solutions.drawing_utils
        
        for confidence in [0.3, 0.5, 0.7]:
            pose = mp_pose.Pose(
                min_detection_confidence=confidence,
                min_tracking_confidence=confidence,
                model_complexity=1
            )
            
            # Convert to RGB
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            
            # Process
            results = pose.process(rgb_frame)
            
            # Draw results
            test_frame = frame.copy()
            if results.pose_landmarks:
                mp_drawing.draw_landmarks(
                    test_frame,
                    results.pose_landmarks,
                    mp_pose.POSE_CONNECTIONS
                )
                print(f"✅ Confidence {confidence}: DETECTED {len(results.pose_landmarks.landmark)} landmarks")
                cv2.imwrite(f'debug_frame_detected_conf_{confidence}.jpg', test_frame)
            else:
                print(f"❌ Confidence {confidence}: NO POSE DETECTED")
                cv2.imwrite(f'debug_frame_no_detection_conf_{confidence}.jpg', test_frame)
            
            pose.close()
            
    except Exception as e:
        print(f"❌ Error in static image test: {e}")


if __name__ == "__main__":
    print("="*60)
    print("MediaPipe Pose Detection Test")
    print("="*60)
    print("\nThis script will test MediaPipe pose detection:")
    print("1. First with your webcam (live)")
    print("2. Then with the debug_frame.jpg (if it exists)")
    print("\nInstructions for webcam test:")
    print("- Stand 6-8 feet from camera")
    print("- Ensure good lighting")
    print("- Full upper body visible")
    print("- Press 'q' to quit")
    print("- Press 's' to save current frame")
    print("- Press SPACE to try next confidence level")
    print()
    
    input("Press ENTER to start webcam test...")
    
    # Test with webcam
    test_mediapipe_webcam()
    
    # Test with static image
    test_with_image()
    
    print("\n" + "="*60)
    print("Test complete!")
    print("="*60)
