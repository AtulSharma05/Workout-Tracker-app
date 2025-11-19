# Pose Corrector API Startup Script
# Requires Python 3.10

Write-Host "🤖 Starting Pose Corrector API..." -ForegroundColor Cyan
Write-Host ""

# Check if Python 3.10 is installed
$python310 = Get-Command py -ErrorAction SilentlyContinue | Where-Object { (& $_.Source -3.10 --version 2>&1) -match "Python 3.10" }

if (-not $python310) {
    Write-Host "❌ Python 3.10 not found!" -ForegroundColor Red
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

Write-Host "✅ Python 3.10 found" -ForegroundColor Green
Write-Host ""

# Create virtual environment if it doesn't exist
if (-not (Test-Path "venv-py310")) {
    Write-Host "📦 Creating Python 3.10 virtual environment..." -ForegroundColor Yellow
    py -3.10 -m venv venv-py310
    Write-Host "✅ Virtual environment created" -ForegroundColor Green
    Write-Host ""
}

# Activate virtual environment
Write-Host "🔌 Activating virtual environment..." -ForegroundColor Yellow
& .\venv-py310\Scripts\Activate.ps1

# Install/update dependencies
Write-Host "📦 Checking dependencies..." -ForegroundColor Yellow
$installed = pip show mediapipe 2>$null
if (-not $installed) {
    Write-Host "Installing dependencies (this may take a few minutes)..." -ForegroundColor Yellow
    Write-Host ""
    
    # Install core dependencies
    pip install opencv-python mediapipe numpy pandas --quiet
    
    # Try PyTorch (CPU version for lighter install)
    Write-Host "Installing PyTorch..." -ForegroundColor Yellow
    pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu --quiet
    
    # Try scikit-learn
    pip install scikit-learn --quiet 2>$null
    
    Write-Host ""
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✅ Dependencies already installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🎯 Pose Corrector API" -ForegroundColor Cyan
Write-Host "  Port: 8001" -ForegroundColor Cyan
Write-Host "  Python: 3.10 (venv-py310)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 API will run on: http://localhost:8001" -ForegroundColor White
Write-Host "📍 WebSocket: ws://localhost:8001/ws/pose-analysis" -ForegroundColor White
Write-Host "📍 Docs: http://localhost:8001/docs" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

# Install FastAPI dependencies if needed
Write-Host "📦 Installing API dependencies..." -ForegroundColor Yellow
pip install fastapi uvicorn[standard] websockets python-multipart --quiet

Write-Host ""
Write-Host "🚀 Starting Pose Corrector API..." -ForegroundColor Green
Write-Host ""

# Start the API
python pose_corrector_api.py
