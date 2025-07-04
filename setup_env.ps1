# PowerShell script to set up environment variables
# This script copies the example environment file to create a local .env file

Write-Host "Setting up environment variables..." -ForegroundColor Green

# Check if .env already exists
if (Test-Path ".env") {
    Write-Host "Warning: .env file already exists. Do you want to overwrite it? (y/N)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Setup cancelled." -ForegroundColor Red
        exit 1
    }
}

# Copy the example file
if (Test-Path "env.example") {
    Copy-Item "env.example" ".env"
    Write-Host "Environment file created successfully!" -ForegroundColor Green
    Write-Host "Please edit .env file to configure your settings." -ForegroundColor Cyan
} else {
    Write-Host "Error: env.example file not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Edit .env file to set your API_BASE_URL and other settings" -ForegroundColor White
Write-Host "2. Run 'flutter pub get' to install dependencies" -ForegroundColor White
Write-Host "3. Run 'flutter run' to start the app" -ForegroundColor White 