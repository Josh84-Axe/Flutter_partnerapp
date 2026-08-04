# Fix Development Environment PATH Issues
# This script fixes common Windows PATH problems after installing development tools

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Environment PATH Fix Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to add to PATH if not already present
function Add-ToPath {
    param([string]$PathToAdd)
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$PathToAdd*") {
        Write-Host "Adding to PATH: $PathToAdd" -ForegroundColor Yellow
        [Environment]::SetEnvironmentVariable(
            "Path",
            "$currentPath;$PathToAdd",
            "User"
        )
        return $true
    }
    else {
        Write-Host "Already in PATH: $PathToAdd" -ForegroundColor Green
        return $false
    }
}

# Check and fix Python PATH
Write-Host "`n[1/3] Checking Python..." -ForegroundColor Cyan
$pythonPath = "C:\Users\ELITEX21012G2\AppData\Local\Programs\Python\Python311"
$pythonScriptsPath = "C:\Users\ELITEX21012G2\AppData\Local\Programs\Python\Python311\Scripts"

if (Test-Path "$pythonPath\python.exe") {
    Write-Host "  Python found at: $pythonPath" -ForegroundColor Green
    Add-ToPath $pythonPath
    Add-ToPath $pythonScriptsPath
}
else {
    Write-Host "  Python not found at expected location" -ForegroundColor Red
}

# Check and fix Postman PATH
Write-Host "`n[2/3] Checking Postman..." -ForegroundColor Cyan
$postmanPath = "C:\Users\ELITEX21012G2\AppData\Local\Postman"
if (Test-Path "$postmanPath\Postman.exe") {
    Write-Host "  Postman found at: $postmanPath" -ForegroundColor Green
    Add-ToPath $postmanPath
}
else {
    Write-Host "  Postman not found at expected location" -ForegroundColor Red
}

# Check and fix scrcpy PATH
Write-Host "`n[3/3] Checking scrcpy..." -ForegroundColor Cyan
$scrcpyPath = "C:\Program Files\scrcpy"
if (Test-Path "$scrcpyPath\scrcpy.exe") {
    Write-Host "  scrcpy found at: $scrcpyPath" -ForegroundColor Green
    Add-ToPath $scrcpyPath
}
else {
    Write-Host "  scrcpy not found at expected location" -ForegroundColor Red
}

# Reload PATH in current session
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Reloading PATH in current session..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Verify installations
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Verification Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nPython:" -ForegroundColor Yellow
try {
    $pythonVersion = & python --version 2>&1
    Write-Host "  ✓ $pythonVersion" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Not accessible in PATH" -ForegroundColor Red
    Write-Host "  → Try: C:\Users\ELITEX21012G2\AppData\Local\Programs\Python\Python311\python.exe --version" -ForegroundColor Gray
}

Write-Host "`nPostman:" -ForegroundColor Yellow
try {
    $postmanVersion = & postman --version 2>&1
    Write-Host "  ✓ Version: $postmanVersion" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Not accessible in PATH (Postman may not have CLI)" -ForegroundColor Yellow
    Write-Host "  → Launch from Start Menu instead" -ForegroundColor Gray
}

Write-Host "`nscrcpy:" -ForegroundColor Yellow
try {
    $scrcpyVersion = & scrcpy --version 2>&1
    Write-Host "  ✓ $scrcpyVersion" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Not accessible in PATH" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Next Steps" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. CLOSE this terminal completely" -ForegroundColor Yellow
Write-Host "2. OPEN a new terminal" -ForegroundColor Yellow
Write-Host "3. Run: python --version" -ForegroundColor Yellow
Write-Host ""
Write-Host "If Python still doesn't work:" -ForegroundColor Cyan
Write-Host "  → Disable Windows Store Python alias:" -ForegroundColor Gray
Write-Host "    Settings > Apps > App execution aliases" -ForegroundColor Gray
Write-Host "    Turn OFF 'python.exe' and 'python3.exe'" -ForegroundColor Gray
Write-Host ""
Write-Host "Script completed!" -ForegroundColor Green
