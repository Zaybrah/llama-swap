# Windows PowerShell build script for llama-swap
# Usage: Run this script from the project root in PowerShell


$ErrorActionPreference = 'Stop'

# Ensure build directory exists
if (!(Test-Path "build")) {
	New-Item -ItemType Directory -Path "build" | Out-Null
}

# Build React UI
Write-Host "Building React UI..."
Push-Location ui
npm install
npm run build
Pop-Location

# Get Git hash
$gitHash = git rev-parse --short HEAD
$status = git status --porcelain
if ($status) { $gitHash += '+' }

# Get build date in RFC3339 format (UTC)
$buildDate = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

# Build main Windows binary
Write-Host "Building Windows binary..."
go build -ldflags="-X main.commit=$gitHash -X main.version=local_$gitHash -X main.date=$buildDate" -o build/llama-swap-windows-amd64.exe llama-swap.go

# Build simple-responder for Windows
Write-Host "Building simple responder for Windows..."
go build -o build/simple-responder.exe misc/simple-responder/simple-responder.go

# Run tests
Write-Host "Running tests..."
go test -short -v -count=1 ./proxy

Write-Host "Build and tests completed. Output: build/llama-swap-windows-amd64.exe"
