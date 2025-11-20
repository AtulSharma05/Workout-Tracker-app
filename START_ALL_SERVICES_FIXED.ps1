# Complete Workout Tracker - All Services Startup Script
# Handles Python version isolation properly

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Workout Tracker - All Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if port is in use
function Test-Port {
    param($Port)
    $connection = Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue -InformationLevel Quiet
    return $connection
}

# 1. Check MongoDB
Write-Host "1ï¸âƒ£  Checking MongoDB..." -ForegroundColor Yellow
$mongoRunning = Get-Process mongod -ErrorAction SilentlyContinue
if ($mongoRunning) {
    Write-Host "   âœ… MongoDB is running" -ForegroundColor Green
} else {
    Write-Host "   âš ï¸  MongoDB not detected - make sure it's running!" -ForegroundColor Yellow
}
Write-Host ""

# 2. Start Node.js Backend (Port 3000)
Write-Host "2ï¸âƒ£  Starting Node.js Backend..." -ForegroundColor Yellow
cd backend
if (Test-Port 3000) {
    Write-Host "   âš ï¸  Port 3000 already in use - killing existing process" -ForegroundColor Yellow
    Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2
}

Write-Host "   ðŸš€ Launching Node.js server on port 3000..." -ForegroundColor Cyan
$backendPath = (Get-Location).Path
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; npm run dev"
Start-Sleep 3

if (Test-Port 3000) {
    Write-Host "   âœ… Node.js backend running" -ForegroundColor Green
} else {
    Write-Host "   âŒ Failed to start Node.js backend" -ForegroundColor Red
}
Write-Host ""

# 3. Start AI Planner (Python - Any Version, Port 8000)
Write-Host "3ï¸âƒ£  Starting AI Workout Planner..." -ForegroundColor Yellow
cd ai-planner

if (Test-Port 8000) {
    Write-Host "   âš ï¸  Port 8000 already in use - killing existing process" -ForegroundColor Yellow
    Get-Process -Name python -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2
}

Write-Host "   ðŸš€ Launching AI Planner on port 8000..." -ForegroundColor Cyan
Write-Host "   (Using Windows Python 3.13)" -ForegroundColor Gray
$aiPlannerPath = (Get-Location).Path
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$aiPlannerPath'; C:\Users\hp\AppData\Local\Programs\Python\Python313\python.exe api_server.py"
Start-Sleep 3

if (Test-Port 8000) {
    Write-Host "   âœ… AI Planner running" -ForegroundColor Green
} else {
    Write-Host "   âŒ Failed to start AI Planner" -ForegroundColor Red
}
Write-Host ""

# 4. Pose Corrector (Python 3.10 Required, Port 8001)
Write-Host "4ï¸âƒ£  Pose Corrector API..." -ForegroundColor Yellow

cd ..\pose-corrector

if (Test-Port 8001) {
    Write-Host "   âš ï¸  Port 8001 already in use - skipping" -ForegroundColor Yellow
} else {
    # Check if Python 3.10 is available
    $python310 = $null
    try {
        $python310 = & py -3.10 --version 2>&1
    } catch {}
    
    if ($python310 -match "Python 3.10") {
        Write-Host "   âœ… Python 3.10 detected" -ForegroundColor Green
        
        # Check if venv exists
        if (Test-Path "venv-py310") {
            Write-Host "   ðŸš€ Launching Pose Corrector on port 8001..." -ForegroundColor Cyan
            $posePath = (Get-Location).Path
            Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$posePath'; .\start_pose_api.ps1"
            Start-Sleep 4
            
            if (Test-Port 8001) {
                Write-Host "   âœ… Pose Corrector running" -ForegroundColor Green
            } else {
                Write-Host "   âš ï¸  Pose Corrector starting (check the window)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ðŸ“¦ First-time setup needed" -ForegroundColor Yellow
            Write-Host "   Run: cd backend\pose-corrector; .\start_pose_api.ps1" -ForegroundColor Gray
        }
    } else {
        Write-Host "   âŒ Python 3.10 not installed" -ForegroundColor Red
        Write-Host "   MediaPipe requires Python 3.10-3.11 (not compatible with 3.13)" -ForegroundColor Gray
        Write-Host "   Download: https://www.python.org/downloads/" -ForegroundColor Gray
        Write-Host "   Note: App works fine without pose tracking" -ForegroundColor Cyan
    }
}

cd ..\..
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ðŸŽ‰ Services Status" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "âœ… Backend API:        http://localhost:3000/api/v1" -ForegroundColor White
Write-Host "âœ… AI Planner:         http://localhost:8000" -ForegroundColor White

# Check if port 8001 is active
if (Test-Port 8001) {
    Write-Host "âœ… Pose Corrector:     http://localhost:8001" -ForegroundColor White
    Write-Host "   WebSocket:          ws://localhost:8001/ws/pose-analysis" -ForegroundColor Gray
    Write-Host "   Pose Docs:          http://localhost:8001/docs" -ForegroundColor Gray
} else {
    Write-Host "â³ Pose Corrector:     Not running (requires Python 3.10)" -ForegroundColor Yellow
}

Write-Host "   Health:             http://localhost:3000/health" -ForegroundColor Gray
Write-Host "   AI Docs:            http://localhost:8000/docs" -ForegroundColor Gray

Write-Host ""
Write-Host "ðŸ’¡ Next: Run 'flutter run' in frontend folder" -ForegroundColor Cyan
Write-Host ""
Write-Host "â¹ï¸  Close all PowerShell windows to stop services" -ForegroundColor Gray
Write-Host ""


