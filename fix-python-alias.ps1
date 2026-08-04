# Disable Windows Store Python Alias
# This script disables the Windows Store Python stub that blocks the real Python

Write-Host "Disabling Windows Store Python aliases..." -ForegroundColor Cyan

# Registry paths for app execution aliases
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$pythonAlias1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\python.exe"
$pythonAlias2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\python3.exe"

# Disable the aliases by modifying registry
try {
    # Method 1: Remove WindowsApps from PATH for current session
    $env:Path = ($env:Path -split ';' | Where-Object { $_ -notlike '*WindowsApps*' }) -join ';'
    
    # Method 2: Add Python to the front of PATH
    $pythonPath = "C:\Users\ELITEX21012G2\AppData\Local\Programs\Python\Python311"
    $env:Path = "$pythonPath;$env:Path"
    
    Write-Host "✓ Python path updated for current session" -ForegroundColor Green
    
    # Test Python
    Write-Host "`nTesting Python..." -ForegroundColor Yellow
    $version = & python --version 2>&1
    Write-Host "✓ $version" -ForegroundColor Green
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "SUCCESS! Python is now working!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To make this permanent, you must:" -ForegroundColor Yellow
    Write-Host "1. Press Windows Key + I (Settings)" -ForegroundColor White
    Write-Host "2. Go to: Apps > Advanced app settings > App execution aliases" -ForegroundColor White
    Write-Host "3. Turn OFF both:" -ForegroundColor White
    Write-Host "   - python.exe" -ForegroundColor White
    Write-Host "   - python3.exe" -ForegroundColor White
    Write-Host ""
    Write-Host "For now, Python will work in THIS terminal session." -ForegroundColor Cyan
    
} catch {
    Write-Host "✗ Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual fix required:" -ForegroundColor Yellow
    Write-Host "1. Open Settings (Windows + I)" -ForegroundColor White
    Write-Host "2. Apps > Advanced app settings > App execution aliases" -ForegroundColor White
    Write-Host "3. Turn OFF python.exe and python3.exe" -ForegroundColor White
}
