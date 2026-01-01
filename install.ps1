# PersistenceAI Web Installer (PowerShell)
# This script can be downloaded and executed via:
#   iwr -useb https://persistenceai.com/install | iex
#   curl -fsSL https://persistenceai.com/install.ps1 | powershell -ExecutionPolicy Bypass -Command -

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Info { param([string]$msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Success { param([string]$msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Error { param([string]$msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Warning { param([string]$msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║     PersistenceAI Installer           ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Configuration
$BASE_URL = "https://persistence-ai.github.io/Landing"
$APP_NAME = "persistenceai"
$INSTALL_DIR = "$env:USERPROFILE\.persistenceai\bin"
$TEMP_DIR = "$env:TEMP\persistenceai-install"

# Detect platform and architecture
$os = "windows"
$arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }

if ($arch -ne "x64") {
    Write-Error "Unsupported architecture: $arch. PersistenceAI requires x64."
    exit 1
}

$platform = "$os-$arch"
$zipName = "$APP_NAME-$platform.zip"

# Determine version
$Version = $null
if ($args.Count -gt 0) {
    $Version = $args[0]
    Write-Info "Installing version: $Version"
} else {
    Write-Info "Fetching latest version..."
    try {
        # Try to get latest version from API
        $latestResponse = Invoke-RestMethod -Uri "$BASE_URL/api/latest.json" -ErrorAction SilentlyContinue
        if ($latestResponse.version) {
            $Version = $latestResponse.version
        }
    } catch {
        # Fallback: try GitHub API if website API not available
        try {
            $ghResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/Persistence-AI/Landing/releases/latest" -ErrorAction SilentlyContinue
            if ($ghResponse.tag_name) {
                $Version = $ghResponse.tag_name -replace '^v', ''
            }
        } catch {
            Write-Warning "Could not fetch latest version, using GitHub Releases"
            $Version = "latest"
        }
    }
    
    if (-not $Version) {
        $Version = "latest"
    }
    Write-Info "Installing version: $Version"
}

# Build download URL - direct from GitHub Releases (like OpenCode)
Write-Info "Getting download URL from GitHub Releases..."

# If version is "latest", fetch the actual version first
if ($Version -eq "latest") {
    Write-Info "Fetching latest version..."
    try {
        # Try website API first
        $latestResponse = Invoke-RestMethod -Uri "$BASE_URL/api/latest.json" -ErrorAction SilentlyContinue
        if ($latestResponse.version) {
            $Version = $latestResponse.version
        }
    } catch {
        # Fallback: try GitHub API directly
        try {
            $ghResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/Persistence-AI/Landing/releases/latest" -ErrorAction SilentlyContinue
            if ($ghResponse.tag_name) {
                $Version = $ghResponse.tag_name -replace '^v', ''
            }
        } catch {
            Write-Warning "Could not fetch latest version, will try 'latest' download URL"
        }
    }
}

# Build direct GitHub Releases URL (like OpenCode)
# Query GitHub API to find the actual asset filename
Write-Info "Finding Windows x64 asset in release v$Version..."
try {
    if ($Version -eq "latest") {
        $releaseUrl = "https://api.github.com/repos/Persistence-AI/Landing/releases/latest"
    } else {
        $releaseUrl = "https://api.github.com/repos/Persistence-AI/Landing/releases/tags/v$Version"
    }
    
    $release = Invoke-RestMethod -Uri $releaseUrl -ErrorAction Stop
    
    # Update version from release tag if needed
    if ($Version -eq "latest") {
        $Version = $release.tag_name -replace '^v', ''
        Write-Info "Latest version: $Version"
    }
    
    # Find Windows x64 zip asset
    $windowsAsset = $release.assets | Where-Object { 
        ($_.name -like "*windows*x64*.zip") -or 
        ($_.name -like "*win*x64*.zip")
    } | Select-Object -First 1
    
    if ($windowsAsset) {
        $downloadUrl = $windowsAsset.browser_download_url
        Write-Info "Found asset: $($windowsAsset.name)"
    } else {
        # Fallback: try standard naming pattern
        $downloadUrl = "https://github.com/Persistence-AI/Landing/releases/download/v$Version/persistenceai-windows-x64-v$Version.zip"
        Write-Warning "Asset not found via API, trying standard URL pattern"
    }
} catch {
    # Fallback to standard URL pattern if API fails
    if ($Version -eq "latest") {
        $downloadUrl = "https://github.com/Persistence-AI/Landing/releases/latest/download/persistenceai-windows-x64.zip"
    } else {
        $downloadUrl = "https://github.com/Persistence-AI/Landing/releases/download/v$Version/persistenceai-windows-x64-v$Version.zip"
    }
    Write-Warning "Could not query GitHub API, using standard URL pattern"
}

Write-Info "Download URL: $downloadUrl"

# Check if already installed
$existingPath = Get-Command -Name $APP_NAME -ErrorAction SilentlyContinue
if ($existingPath) {
    Write-Info "PersistenceAI is already installed at: $($existingPath.Source)"
    $currentVersion = & $existingPath.Source --version 2>&1 | Select-Object -First 1
    Write-Info "Current version: $currentVersion"
    
    # Detect if running non-interactively (piped from web via iwr | iex)
    # When stdin is redirected, Read-Host will fail or hang
    $isNonInteractive = [Console]::IsInputRedirected
    
    # Handle different scenarios
    if ($currentVersion -ne $Version) {
        # Versions differ - always upgrade (user wants new version)
        Write-Info "Upgrading from $currentVersion to $Version..."
    } elseif ($isNonInteractive) {
        # Same version but non-interactive (website link) - always reinstall
        # This allows bug fixes and updates to same version to be applied
        Write-Info "Reinstalling version $Version (applying latest changes)..."
    } else {
        # Same version and interactive - ask user
        Write-Info "Version $Version is already installed."
        $reinstall = Read-Host "Reinstall anyway? (y/N)"
        if ($reinstall -ne "y" -and $reinstall -ne "Y") {
            Write-Success "Installation skipped."
            exit 0
        }
        Write-Info "Reinstalling version $Version..."
    }
    # Continue with installation (will overwrite existing binary)
}

# Create directories
Write-Info "Creating installation directory: $INSTALL_DIR"
New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null

Write-Info "Creating temporary directory: $TEMP_DIR"
if (Test-Path $TEMP_DIR) {
    Remove-Item $TEMP_DIR -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $TEMP_DIR | Out-Null

# Download
Write-Info "Downloading PersistenceAI from: $downloadUrl"
$zipPath = Join-Path $TEMP_DIR $zipName
try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -ErrorAction Stop
    Write-Success "Download completed"
} catch {
    Write-Error "Download failed: $_"
    Write-Error "URL attempted: $downloadUrl"
    Write-Info ""
    Write-Info "Please check:"
    Write-Info "1. The version exists in GitHub Releases: https://github.com/Persistence-AI/Landing/releases"
    Write-Info "2. The file name matches: persistenceai-windows-x64-v$Version.zip (or similar)"
    Write-Info "3. Your internet connection is working"
    Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Verify download
if (-not (Test-Path $zipPath)) {
    Write-Error "Downloaded file not found"
    Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Extract
Write-Info "Extracting archive..."
try {
    Expand-Archive -Path $zipPath -DestinationPath $TEMP_DIR -Force
    
    # Find executable (could be in bin/ subdirectory or root)
    # Try persistenceai.exe first (for backward compatibility)
    $exePath = Join-Path $TEMP_DIR "bin\$APP_NAME.exe"
    if (-not (Test-Path $exePath)) {
        $exePath = Join-Path $TEMP_DIR "$APP_NAME.exe"
    }
    
    # Also check for pai.exe (alternative command name)
    $paiExePath = Join-Path $TEMP_DIR "bin\pai.exe"
    if (-not (Test-Path $paiExePath)) {
        $paiExePath = Join-Path $TEMP_DIR "pai.exe"
    }
    
    if (-not (Test-Path $exePath) -and -not (Test-Path $paiExePath)) {
        throw "Executable not found in archive. Contents: $((Get-ChildItem $TEMP_DIR -Recurse | Select-Object -First 10 | ForEach-Object { $_.FullName }) -join ', ')"
    }
    
    # Install both commands: 'pai' and 'persistenceai'
    # Remove existing binaries first to ensure clean overwrite
    if (Test-Path $INSTALL_DIR) {
        $existingBinaries = Get-ChildItem -Path $INSTALL_DIR -Filter "*.exe" -ErrorAction SilentlyContinue
        foreach ($existing in $existingBinaries) {
            Remove-Item -Path $existing.FullName -Force -ErrorAction SilentlyContinue
        }
    }
    
    if (Test-Path $exePath) {
        $targetPath = Join-Path $INSTALL_DIR "$APP_NAME.exe"
        Copy-Item -Path $exePath -Destination $targetPath -Force
        Write-Success "Installed 'persistenceai' command"
    }
    
    if (Test-Path $paiExePath) {
        $paiTargetPath = Join-Path $INSTALL_DIR "pai.exe"
        Copy-Item -Path $paiExePath -Destination $paiTargetPath -Force
        Write-Success "Installed 'pai' command"
    } elseif (Test-Path $exePath) {
        # If only persistenceai.exe exists, create pai.exe as a copy
        $paiTargetPath = Join-Path $INSTALL_DIR "pai.exe"
        Copy-Item -Path $exePath -Destination $paiTargetPath -Force
        Write-Success "Installed 'pai' command (created from persistenceai.exe)"
    }
    
    # Verify installed binary is production
    if (Test-Path $targetPath) {
        try {
            $installedVersion = & $targetPath --version 2>&1 | Select-Object -First 1
            if ($installedVersion -match "0\.0\.0-local") {
                Write-Warning "⚠️  Installed binary appears to be DEV version (0.0.0-local-*)"
                Write-Warning "   This should not happen with production ZIP. Please report this issue."
            } elseif ($installedVersion -match "1\.\d+\.\d+") {
                Write-Success "Verified installed binary is production version: $installedVersion"
            }
        } catch {
            # Ignore verification errors
        }
    }
    
    Write-Success "Extraction completed - both 'pai' and 'persistenceai' commands available"
} catch {
    Write-Error "Extraction failed: $_"
    Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Cleanup
Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue

# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$INSTALL_DIR*") {
    Write-Info "Adding PersistenceAI to PATH..."
    $newPath = "$currentPath;$INSTALL_DIR"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    
    # Also add to current session
    $env:Path += ";$INSTALL_DIR"
    Write-Success "Added to PATH"
} else {
    Write-Info "PersistenceAI is already in PATH"
}

# Verify installation
Write-Info "Verifying installation..."
$exeFullPath = Join-Path $INSTALL_DIR "$APP_NAME.exe"
if (Test-Path $exeFullPath) {
    try {
        $versionOutput = & $exeFullPath --version 2>&1 | Select-Object -First 1
        Write-Host ""
        Write-Success "Installation successful!"
        Write-Host ""
        Write-Info "PersistenceAI version: $versionOutput"
        Write-Info "Installation location: $INSTALL_DIR"
        Write-Host ""
        Write-Warning "Note: You may need to restart PowerShell for the PATH changes to take effect."
        Write-Host ""
        Write-Info "To use PersistenceAI, open a new PowerShell window and run: $APP_NAME"
        Write-Info "For more information, visit: $BASE_URL/docs"
        Write-Host ""
    } catch {
        Write-Warning "Installation completed, but version check failed. You may need to restart PowerShell."
        Write-Info "Try running: $exeFullPath --version"
    }
} else {
    Write-Error "Installation verification failed: executable not found"
    exit 1
}
