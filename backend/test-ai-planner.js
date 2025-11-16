/**
 * Test script for AI Workout Planner integration
 * 
 * This script tests:
 * 1. Python AI server connectivity
 * 2. Workout plan generation
 * 3. Exercise recommendations
 * 4. Sets/reps prediction
 */

const fetch = require('node-fetch');

const BASE_URL = 'http://localhost:8000';

// ANSI color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function testHealthCheck() {
  log('\n📊 Testing Health Check...', 'cyan');
  try {
    const response = await fetch(`${BASE_URL}/health`);
    const data = await response.json();
    
    if (response.ok && data.status === 'healthy') {
      log('✅ Health check passed', 'green');
      log(`   ML Model: ${data.ml_model}`, 'blue');
      log(`   LLM: ${data.llm}`, 'blue');
      return true;
    } else {
      log('❌ Health check failed', 'red');
      return false;
    }
  } catch (error) {
    log(`❌ Health check error: ${error.message}`, 'red');
    return false;
  }
}

async function testGeneratePlan() {
  log('\n🏋️  Testing Workout Plan Generation...', 'cyan');
  try {
    const requestData = {
      goal: 'muscle_gain',
      experience: 'intermediate',
      daysPerWeek: 4,
      equipment: ['Dumbbell', 'Barbell', 'Bodyweight'],
      targetMuscles: ['Chest', 'Back', 'Legs'],
      duration: 60
    };

    log(`   Request: ${JSON.stringify(requestData, null, 2)}`, 'yellow');

    const response = await fetch(`${BASE_URL}/generate-plan`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestData),
    });

    const data = await response.json();

    if (response.ok && data.plan) {
      log('✅ Plan generation successful', 'green');
      log(`   Goal: ${data.plan.goal}`, 'blue');
      log(`   Experience: ${data.plan.experience}`, 'blue');
      log(`   Days per week: ${data.plan.daysPerWeek}`, 'blue');
      log(`   Generated ${data.plan.days?.length || 0} workout days`, 'blue');
      
      if (data.plan.days && data.plan.days.length > 0) {
        const day1 = data.plan.days[0];
        log(`   Day 1: ${day1.focus} (${day1.exercises?.length || 0} exercises)`, 'blue');
      }
      return true;
    } else {
      log('❌ Plan generation failed', 'red');
      log(`   Error: ${data.error || 'Unknown error'}`, 'red');
      return false;
    }
  } catch (error) {
    log(`❌ Plan generation error: ${error.message}`, 'red');
    return false;
  }
}

async function testExerciseRecommendations() {
  log('\n💪 Testing Exercise Recommendations...', 'cyan');
  try {
    const requestData = {
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      difficulty: 'intermediate',
      limit: 5
    };

    log(`   Request: ${JSON.stringify(requestData, null, 2)}`, 'yellow');

    const response = await fetch(`${BASE_URL}/recommend-exercises`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestData),
    });

    const data = await response.json();

    if (response.ok && data.exercises) {
      log('✅ Exercise recommendations successful', 'green');
      log(`   Found ${data.exercises.length} exercises`, 'blue');
      
      if (data.exercises.length > 0) {
        log('   Top recommendations:', 'blue');
        data.exercises.slice(0, 3).forEach((ex, i) => {
          log(`     ${i + 1}. ${ex.name} (${ex.equipment || 'N/A'})`, 'blue');
        });
      }
      return true;
    } else {
      log('❌ Exercise recommendations failed', 'red');
      log(`   Error: ${data.error || 'Unknown error'}`, 'red');
      return false;
    }
  } catch (error) {
    log(`❌ Exercise recommendations error: ${error.message}`, 'red');
    return false;
  }
}

async function testPredictSetsReps() {
  log('\n🎯 Testing Sets/Reps Prediction...', 'cyan');
  try {
    const requestData = {
      exercise: 'Bench Press',
      goal: 'muscle_gain',
      experience: 'intermediate'
    };

    log(`   Request: ${JSON.stringify(requestData, null, 2)}`, 'yellow');

    const response = await fetch(`${BASE_URL}/predict-sets-reps`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestData),
    });

    const data = await response.json();

    if (response.ok && data.prediction) {
      log('✅ Sets/Reps prediction successful', 'green');
      log(`   Sets: ${data.prediction.sets}`, 'blue');
      log(`   Reps: ${data.prediction.reps}`, 'blue');
      log(`   Rest: ${data.prediction.rest_seconds}s`, 'blue');
      return true;
    } else {
      log('❌ Sets/Reps prediction failed', 'red');
      log(`   Error: ${data.error || 'Unknown error'}`, 'red');
      return false;
    }
  } catch (error) {
    log(`❌ Sets/Reps prediction error: ${error.message}`, 'red');
    return false;
  }
}

async function runAllTests() {
  log('\n' + '='.repeat(60), 'cyan');
  log('  AI WORKOUT PLANNER - INTEGRATION TESTS', 'cyan');
  log('='.repeat(60), 'cyan');

  const results = {
    health: await testHealthCheck(),
    plan: await testGeneratePlan(),
    recommendations: await testExerciseRecommendations(),
    prediction: await testPredictSetsReps(),
  };

  log('\n' + '='.repeat(60), 'cyan');
  log('  TEST RESULTS SUMMARY', 'cyan');
  log('='.repeat(60), 'cyan');

  let passed = 0;
  let total = 0;

  Object.entries(results).forEach(([test, result]) => {
    total++;
    if (result) passed++;
    const status = result ? '✅ PASS' : '❌ FAIL';
    const color = result ? 'green' : 'red';
    log(`  ${status} - ${test.toUpperCase()}`, color);
  });

  log('\n' + '-'.repeat(60), 'cyan');
  log(`  Total: ${passed}/${total} tests passed`, passed === total ? 'green' : 'yellow');
  log('='.repeat(60) + '\n', 'cyan');

  process.exit(passed === total ? 0 : 1);
}

// Run tests
runAllTests().catch(error => {
  log(`\n❌ Fatal error: ${error.message}`, 'red');
  process.exit(1);
});
