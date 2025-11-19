# Pose Corrector API Startup Script
# Requires Python 3.10

Write-Host "Starting Pose Corrector API..." -ForegroundColor Cyan
Write-Host ""

# Check if Python 3.10 is installed
$python310 = $null
try {
    $python310 = & py -3.10 --version 2>&1
} catch {}

if (-not ($python310 -match "Python 3.10")) {
    Write-Host "[ERROR] Python 3.10 not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Python 3.10 from: https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installation Steps:" -ForegroundColor Cyan
    Write-Host "1. Download Python 3.10 installer" -ForegroundColor White
    Write-Host "2. During installation, check 'Add Python to PATH'" -ForegroundColor White
    Write-Host "3. Check 'Install launcher for all users (recommended)'" -ForegroundColor White
    Write-Host "4. Choose 'Customize installation' and select 'py launcher'" -ForegroundColor White
    Write-Host ""
    pause
    exit 1
}

Write-Host "[OK] Python 3.10 found" -ForegroundColor Green
Write-Host ""

# Create virtual environment if it doesn't exist
if (-not (Test-Path "venv-py310")) {
    Write-Host "[SETUP] Creating Python 3.10 virtual environment..." -ForegroundColor Yellow
    py -3.10 -m venv venv-py310
    Write-Host "[OK] Virtual environment created" -ForegroundColor Green
    Write-Host ""
}

# Activate virtual environment
Write-Host "[SETUP] Activating virtual environment..." -ForegroundColor Yellow
& .\venv-py310\Scripts\Activate.ps1

# Install/update dependencies
Write-Host "[CHECK] Checking dependencies..." -ForegroundColor Yellow
$installed = & pip show mediapipe 2>$null
if (-not $installed) {
    Write-Host "[INSTALL] Installing dependencies (this may take a few minutes)..." -ForegroundColor Yellow
    Write-Host ""
    
    # Install core dependencies
    Write-Host "Installing MediaPipe and OpenCV..." -ForegroundColor Gray
    pip install opencv-python mediapipe numpy pandas
    
    # Try PyTorch (CPU version for lighter install)
    Write-Host "Installing PyTorch..." -ForegroundColor Gray
    pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
    
    # Install scikit-learn
    Write-Host "Installing scikit-learn..." -ForegroundColor Gray
    pip install scikit-learn
    
    # Install FastAPI
    Write-Host "Installing FastAPI..." -ForegroundColor Gray
    pip install fastapi uvicorn[standard] websockets python-multipart
    
    Write-Host ""
    Write-Host "[OK] Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "[OK] Dependencies already installed" -ForegroundColor Green
    
    # Make sure FastAPI is installed
    $hasFastapi = & pip show fastapi 2>$null
    if (-not $hasFastapi) {
        Write-Host "[INSTALL] Installing FastAPI..." -ForegroundColor Yellow
        pip install fastapi uvicorn[standard] websockets python-multipart
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Pose Corrector API" -ForegroundColor Cyan
Write-Host "  Port: 8001" -ForegroundColor Cyan
Write-Host "  Python: 3.10 (venv-py310)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "API will run on: http://localhost:8001" -ForegroundColor White
Write-Host "WebSocket:       ws://localhost:8001/ws/pose-analysis" -ForegroundColor White
Write-Host "Docs:            http://localhost:8001/docs" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""
Write-Host "[LAUNCH] Starting Pose Corrector API..." -ForegroundColor Green
Write-Host ""

# Start the API
python pose_corrector_api.py
