#!/usr/bin/env python3
"""
Test bicep curl rep counting with webcam
This will verify the ML model can count reps properly
"""

import cv2
import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

from professional_pose_corrector import ProfessionalPoseCorrector

def test_bicep_curl_reps():
    """Test bicep curl rep counting with live webcam"""
    
    print("="*60)
    print("BICEP CURL REP COUNTER TEST")
    print("="*60)
    print("\nInstructions:")
    print("1. Stand 6-8 feet from your webcam")
    print("2. Full upper body visible")
    print("3. Do slow bicep curls:")
    print("   - Start: Arms straight down")
    print("   - Up: Curl to shoulders")
    print("   - Down: Lower back down")
    print("   - That's 1 rep!")
    print("\nPress 'q' to quit, 'r' to reset count")
    print("="*60)
    
    input("\nPress ENTER to start...")
    
    # Initialize pose corrector
    print("\n⏳ Initializing AI Pose Corrector...")
    corrector = ProfessionalPoseCorrector()
    
    # Set to bicep curl - need BOTH name and ID
    corrector.current_exercise_name = "bicep curl"
    corrector.current_exercise_id = "bicep_curl_001"  # Add exercise ID
    print("✅ Exercise set to: bicep curl")
    
    # Open webcam
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("❌ Could not open webcam")
        return
    
    # Set resolution
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    
    print("✅ Webcam opened - 1280x720")
    print("\n🎯 Start doing bicep curls!\n")
    
    frame_count = 0
    last_rep_count = 0
    
    while True:
        ret, frame = cap.read()
        if not ret:
            print("❌ Failed to read frame")
            break
        
        frame_count += 1
        
        # Process frame
        processed_frame, analysis = corrector.process_frame(frame)
        
        # Debug: Check if pose detected every 30 frames
        if frame_count % 30 == 0:
            if analysis and hasattr(analysis, 'confidence'):
                print(f"🔍 Frame {frame_count}: Confidence={analysis.confidence:.2f}, Landmarks detected={hasattr(analysis, 'landmarks_detected')}")
            else:
                print(f"⚠️ Frame {frame_count}: No analysis returned")
        
        # Display processed frame with skeleton
        if processed_frame is not None:
            display_frame = processed_frame
        else:
            display_frame = frame
        
        # Get current stats
        rep_count = corrector.rep_count
        phase = corrector.current_phase
        
        # Check if new rep was counted
        if rep_count > last_rep_count:
            print(f"🎉 REP {rep_count} COUNTED! (Phase: {phase})")
            last_rep_count = rep_count
        
        # Add overlay text
        cv2.putText(display_frame, f"REPS: {rep_count}", 
                   (20, 60), cv2.FONT_HERSHEY_DUPLEX, 2, (0, 255, 0), 4)
        cv2.putText(display_frame, f"Phase: {phase}", 
                   (20, 120), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 0), 2)
        
        # Show if pose is detected
        if analysis and hasattr(analysis, 'confidence') and analysis.confidence > 0:
            cv2.putText(display_frame, f"✓ Pose Detected", 
                       (20, 180), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
            
            # Show form feedback if any
            if analysis.corrections:
                y_pos = 240
                cv2.putText(display_frame, "Form Tips:", 
                           (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
                for i, tip in enumerate(analysis.corrections[:3]):  # Show max 3 tips
                    y_pos += 30
                    cv2.putText(display_frame, f"- {tip}", 
                               (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)
        else:
            cv2.putText(display_frame, f"✗ No Pose Detected", 
                       (20, 180), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
            cv2.putText(display_frame, "Position yourself properly", 
                       (20, 220), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        
        # Instructions
        cv2.putText(display_frame, "Press 'q' to quit, 'r' to reset", 
                   (20, display_frame.shape[0] - 20), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        
        # Show frame
        cv2.imshow('Bicep Curl Rep Counter Test', display_frame)
        
        # Print status every 30 frames
        if frame_count % 30 == 0:
            print(f"📊 Reps: {rep_count} | Phase: {phase} | Frames: {frame_count}")
        
        # Handle keypresses
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break
        elif key == ord('r'):
            corrector.rep_count = 0
            corrector.phase_history.clear()
            corrector.current_phase = "start"
            last_rep_count = 0
            print("\n🔄 Rep count reset!\n")
    
    # Cleanup
    cap.release()
    cv2.destroyAllWindows()
    
    # Final stats
    print("\n" + "="*60)
    print("TEST COMPLETE!")
    print("="*60)
    print(f"Total Reps Counted: {rep_count}")
    print(f"Total Frames Processed: {frame_count}")
    print(f"Final Phase: {phase}")
    print("="*60)


if __name__ == "__main__":
    try:
        test_bicep_curl_reps()
    except KeyboardInterrupt:
        print("\n\n⚠️ Test interrupted by user")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
