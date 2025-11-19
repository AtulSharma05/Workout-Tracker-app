#!/usr/bin/env python3
"""
Create exercise ID mapping for Workout Tracker integration
Maps common exercise names to pose corrector exercise IDs
"""

import json

def create_exercise_mapping():
    """Create a mapping of common exercise names to IDs"""
    
    # Load the corrected exercise mapping
    with open('data/corrected_exercise_mapping.json', 'r') as f:
        data = json.load(f)
    
    correct_mapping = data.get('correct_mapping', {})
    
    # Create reverse mapping (name -> id) with normalized names
    exercise_id_mapping = {}
    
    # Common exercises that users are likely to search for
    priority_keywords = [
        'bench press', 'squat', 'deadlift', 'curl', 'push up', 'pull up',
        'shoulder press', 'lateral raise', 'row', 'lunge', 'dip',
        'tricep extension', 'bicep', 'chest fly', 'leg press', 'calf raise',
        'sit up', 'crunch', 'plank', 'burpee', 'jumping jack'
    ]
    
    # Build mapping
    for exercise_id, exercise_name in correct_mapping.items():
        # Normalize the name
        normalized_name = exercise_name.lower().strip()
        
        # Add to mapping
        exercise_id_mapping[normalized_name] = exercise_id
        
        # Also add without equipment prefix for easier matching
        # e.g., "barbell bench press" -> "bench press"
        equipment_prefixes = [
            'barbell ', 'dumbbell ', 'cable ', 'smith machine ',
            'lever ', 'band ', 'kettlebell ', 'ez-bar ', 'ez bar ',
            'weighted ', 'bodyweight ', 'suspension ', 'medicine ball '
        ]
        
        for prefix in equipment_prefixes:
            if normalized_name.startswith(prefix):
                simple_name = normalized_name.replace(prefix, '', 1)
                if simple_name not in exercise_id_mapping:
                    exercise_id_mapping[simple_name] = exercise_id
    
    # Save the mapping
    output = {
        "description": "Exercise name to ID mapping for Workout Tracker integration",
        "total_exercises": len(correct_mapping),
        "mapping": exercise_id_mapping,
        "sample_usage": {
            "bench press": exercise_id_mapping.get('bench press', 'N/A'),
            "squat": exercise_id_mapping.get('squat', 'N/A'),
            "bicep curl": exercise_id_mapping.get('bicep curl', 'N/A')
        }
    }
    
    with open('data/exercise_id_mapping.json', 'w') as f:
        json.dump(output, f, indent=2)
    
    print("✅ Exercise ID mapping created!")
    print(f"📊 Total exercises in database: {len(correct_mapping)}")
    print(f"📊 Mapped names (including variants): {len(exercise_id_mapping)}")
    print("\n📝 Sample mappings:")
    
    # Show some examples
    examples = [
        'bench press', 'squat', 'bicep curl', 'push up', 'pull up',
        'shoulder press', 'deadlift', 'lunge', 'tricep extension'
    ]
    
    for name in examples:
        exercise_id = exercise_id_mapping.get(name, 'Not found')
        if exercise_id != 'Not found':
            print(f"   {name}: {exercise_id}")
    
    print(f"\n💾 Saved to: data/exercise_id_mapping.json")

if __name__ == "__main__":
    create_exercise_mapping()
