# PersistenceAI Web Installer (PowerShell)
# This script can be downloaded and executed via:
#   iwr -useb https://persistence-ai.github.io/Landing/install.ps1 | iex
#   curl -fsSL https://persistence-ai.github.io/Landing/install.ps1 | powershell -ExecutionPolicy Bypass -Command -

$ErrorActionPreference = "Stop"

# ============================================================================
# Output Functions (Simple, like OpenCode)
# ============================================================================

function Write-Info { 
    param([string]$msg) 
    Write-Host "  " -NoNewline
    Write-Host "[i]" -ForegroundColor Cyan -NoNewline
    Write-Host " $msg" -ForegroundColor Gray 
}

function Write-Success { 
    param([string]$msg) 
    Write-Host "  " -NoNewline
    Write-Host "[+]" -ForegroundColor Green -NoNewline
    Write-Host " $msg" -ForegroundColor Gray 
}

function Write-Error { 
    param([string]$msg) 
    Write-Host "  " -NoNewline
    Write-Host "[x]" -ForegroundColor Red -NoNewline
    Write-Host " $msg" -ForegroundColor Gray 
}

function Write-Warning { 
    param([string]$msg) 
    Write-Host "  " -NoNewline
    Write-Host "[!]" -ForegroundColor Yellow -NoNewline
    Write-Host " $msg" -ForegroundColor Gray 
}

function Write-Step { 
    param([string]$msg) 
    Write-Host "  " -NoNewline
    Write-Host "[>]" -ForegroundColor Cyan -NoNewline
    Write-Host " $msg" -ForegroundColor White 
}

# ============================================================================
# Banner
# ============================================================================

Write-Host ""
Write-Host "  " -NoNewline; Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  " -NoNewline; Write-Host "|" -ForegroundColor Magenta -NoNewline
Write-Host "     " -NoNewline; Write-Host "PersistenceAI" -ForegroundColor Magenta -NoNewline; Write-Host " Installer" -ForegroundColor White -NoNewline; Write-Host "     " -NoNewline; Write-Host "|" -ForegroundColor Magenta
Write-Host "  " -NoNewline; Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# ============================================================================
# Configuration
# ============================================================================

$BASE_URL = "https://persistence-ai.github.io/Landing"
$APP_NAME = "persistenceai"
$INSTALL_DIR = "$env:USERPROFILE\.persistenceai\bin"
$TEMP_DIR = "$env:TEMP\persistenceai-install"

# Detect platform
$os = "windows"
$arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }

if ($arch -ne "x64") {
    Write-Error "Unsupported architecture: $arch. PersistenceAI requires x64."
    exit 1
}

$platform = "$os-$arch"
$zipName = "$APP_NAME-$platform.zip"

# ============================================================================
# Version Detection
# ============================================================================

function Get-LatestVersion {
    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/api/latest.json" -ErrorAction SilentlyContinue
        if ($response.version) {
            return $response.version
        }
    } catch {
        # Fallback to GitHub API
        try {
            $ghResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/Persistence-AI/Landing/releases/latest" -ErrorAction SilentlyContinue
            if ($ghResponse.tag_name) {
                return $ghResponse.tag_name -replace '^v', ''
            }
        } catch {
            return $null
        }
    }
    return $null
}

# Determine version
$Version = $null
if ($args.Count -gt 0) {
    $Version = $args[0]
    Write-Info "Installing version: $Version"
} else {
    Write-Step "Fetching latest version"
    $Version = Get-LatestVersion
    if (-not $Version) {
        $Version = "latest"
        Write-Warning "Could not fetch latest version, using 'latest'"
    } else {
        Write-Info "Latest version: $Version"
    }
}

# ============================================================================
# Download URL Resolution
# ============================================================================

function Get-DownloadUrl {
    param([string]$Version)
    
    try {
        if ($Version -eq "latest") {
            $releaseUrl = "https://api.github.com/repos/Persistence-AI/Landing/releases/latest"
        } else {
            $releaseUrl = "https://api.github.com/repos/Persistence-AI/Landing/releases/tags/v$Version"
        }
        
        $release = Invoke-RestMethod -Uri $releaseUrl -ErrorAction Stop
        
        # Update version from release tag if needed
        if ($Version -eq "latest") {
            $script:Version = $release.tag_name -replace '^v', ''
        }
        
        # Find Windows x64 zip asset
        $windowsAsset = $release.assets | Where-Object { 
            ($_.name -like "*windows*x64*.zip") -or 
            ($_.name -like "*win*x64*.zip")
        } | Select-Object -First 1
        
        if ($windowsAsset) {
            return $windowsAsset.browser_download_url
        }
    } catch {
        Write-Warning "Could not query GitHub API: $_"
    }
    
    # Fallback to standard URL pattern
    if ($Version -eq "latest") {
        return "https://github.com/Persistence-AI/Landing/releases/latest/download/persistenceai-windows-x64.zip"
    } else {
        return "https://github.com/Persistence-AI/Landing/releases/download/v$Version/persistenceai-windows-x64-v$Version.zip"
    }
}

Write-Step "Getting download URL"
$downloadUrl = Get-DownloadUrl -Version $Version
Write-Info "Download URL: $downloadUrl"

# ============================================================================
# Installation Check
# ============================================================================

$existingPath = Get-Command -Name $APP_NAME -ErrorAction SilentlyContinue
if ($existingPath) {
    Write-Info "PersistenceAI is already installed at: $($existingPath.Source)"
    $currentVersion = & $existingPath.Source --version 2>&1 | Select-Object -First 1
    Write-Info "Current version: $currentVersion"
    
    # Detect if running non-interactively (piped from web via iwr | iex)
    $isNonInteractive = [Console]::IsInputRedirected
    
    if ($currentVersion -ne $Version) {
        Write-Info "Upgrading from $currentVersion to $Version..."
    } elseif ($isNonInteractive) {
        # Same version but non-interactive - always reinstall (like OpenCode)
        Write-Info "Reinstalling version $Version (applying latest changes)..."
    } else {
        Write-Info "Version $Version is already installed."
        $reinstall = Read-Host "Reinstall anyway? (y/N)"
        if ($reinstall -ne "y" -and $reinstall -ne "Y") {
            Write-Success "Installation skipped."
            exit 0
        }
        Write-Info "Reinstalling version $Version..."
    }
}

# ============================================================================
# Download Function (Simplified)
# ============================================================================

function Get-Binary {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    
    Write-Step "Downloading PersistenceAI..."
    Write-Info "Source: $Url"
    
    $ProgressPreference = 'SilentlyContinue'
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Url, $OutputPath)
        $webClient.Dispose()
        
        if (-not (Test-Path $OutputPath)) {
            throw "Downloaded file not found"
        }
        
        $fileSize = (Get-Item $OutputPath).Length
        if ($fileSize -eq 0) {
            throw "Downloaded file is empty"
        }
        
        Write-Success "Download completed ($([math]::Round($fileSize/1MB, 2)) MB)"
        return $true
    } catch {
        Write-Error "Download failed: $_"
        return $false
    }
}

# ============================================================================
# Installation Function (Simple, like OpenCode's mv)
# ============================================================================

function Install-Binary {
    param(
        [string]$SourcePath,
        [string]$TargetPath
    )
    
    # Debug: Show source file modification time
    if (Test-Path $SourcePath) {
        $sourceFile = Get-Item $SourcePath
        $sourceModTime = $sourceFile.LastWriteTime
        $timeSinceSource = (Get-Date) - $sourceModTime
        Write-Info "Source file modified: $sourceModTime ($([math]::Round($timeSinceSource.TotalMinutes, 1)) minutes ago)"
    }
    
    # Stop running processes (simple, like OpenCode)
    $processes = Get-Process | Where-Object {
        ($_.ProcessName -eq "pai") -or 
        ($_.ProcessName -eq "persistenceai")
    } -ErrorAction SilentlyContinue
    
    if ($processes) {
        Write-Info "Stopping running processes..."
        foreach ($proc in $processes) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Seconds 2
    }
    
    # Debug: Show existing target file modification time (if it exists)
    if (Test-Path $TargetPath) {
        $oldFile = Get-Item $TargetPath
        $oldModTime = $oldFile.LastWriteTime
        $timeSinceOld = (Get-Date) - $oldModTime
        Write-Info "Existing file modified: $oldModTime ($([math]::Round($timeSinceOld.TotalMinutes, 1)) minutes ago)"
        Write-Info "Removing existing file..."
        try {
            Remove-Item -Path $TargetPath -Force -ErrorAction Stop
        } catch {
            Write-Warning "Could not remove existing file: $_"
            Write-Info "Attempting to continue anyway..."
        }
    }
    
    # Atomic move (like OpenCode's mv command)
    Write-Info "Installing binary..."
    try {
        Move-Item -Path $SourcePath -Destination $TargetPath -Force -ErrorAction Stop
        
        # Debug: Verify installed file modification time
        Start-Sleep -Milliseconds 500  # Give Windows time to update metadata
        if (Test-Path $TargetPath) {
            $installedFile = Get-Item $TargetPath
            $installedModTime = $installedFile.LastWriteTime
            $timeSinceInstalled = (Get-Date) - $installedModTime
            Write-Info "Installed file modified: $installedModTime ($([math]::Round($timeSinceInstalled.TotalMinutes, 2)) minutes ago)"
            
            # Warn if modification time is old (more than 2 minutes)
            if ($timeSinceInstalled.TotalMinutes -gt 2) {
                Write-Warning "WARNING: Installed file modification time is $([math]::Round($timeSinceInstalled.TotalMinutes, 1)) minutes old!"
                Write-Warning "This may indicate the file was not properly updated."
            } else {
                Write-Success "Binary installed successfully (file timestamp verified)"
            }
        }
        
        return $true
    } catch {
        Write-Error "Installation failed: $_"
        return $false
    }
}

# ============================================================================
# PATH Management
# ============================================================================

function Update-Path {
    param([string]$InstallDir)
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    if ($currentPath -notlike "*$InstallDir*") {
        Write-Step "Adding PersistenceAI to PATH..."
        # Prepend to PATH to ensure our executables take precedence
        $newPath = "$InstallDir;$currentPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        $env:Path = "$InstallDir;$env:Path"
        Write-Success "PATH updated successfully"
    } else {
        Write-Info "Already in PATH"
        # Ensure it's at the beginning
        $pathParts = $currentPath -split ';'
        if ($pathParts[0] -ne $InstallDir) {
            $pathParts = $pathParts | Where-Object { $_ -ne $InstallDir }
            $newPath = "$InstallDir;" + ($pathParts -join ';')
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            $env:Path = "$InstallDir;$env:Path"
            Write-Info "Moved PersistenceAI to beginning of PATH"
        }
    }
}

# ============================================================================
# Uninstall Function (Enhanced with File Lock Handling)
# ============================================================================

function Uninstall-PersistenceAI {
    Write-Step "Uninstalling PersistenceAI..."
    
    # Stop processes aggressively (including child processes)
    $processes = Get-Process | Where-Object {
        ($_.ProcessName -eq "pai") -or 
        ($_.ProcessName -eq "persistenceai")
    } -ErrorAction SilentlyContinue
    
    if ($processes) {
        Write-Info "Stopping running processes (including child processes)..."
        foreach ($proc in $processes) {
            try {
                # Use taskkill with /T to kill process tree
                Start-Process -FilePath "taskkill" -ArgumentList "/F", "/T", "/PID", $proc.Id -Wait -NoNewWindow -ErrorAction SilentlyContinue | Out-Null
            } catch {
                # Fallback to Stop-Process
                Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            }
        }
        Start-Sleep -Seconds 3
    }
    
    # Remove directories with retry logic
    $dirsToRemove = @(
        "$env:USERPROFILE\.persistenceai",
        "$env:USERPROFILE\.pai",
        "$env:USERPROFILE\.config\persistenceai",
        "$env:USERPROFILE\.config\pai",
        "$env:LOCALAPPDATA\persistenceai",
        "$env:LOCALAPPDATA\pai"
    )
    
    # Also find installation directories from PATH
    $paiCmd = Get-Command -Name "pai" -ErrorAction SilentlyContinue
    $persistenceaiCmd = Get-Command -Name "persistenceai" -ErrorAction SilentlyContinue
    
    if ($paiCmd) {
        $binDir = Split-Path $paiCmd.Source -Parent
        $installDir = Split-Path $binDir -Parent
        if ($installDir -and $installDir -notin $dirsToRemove) {
            $dirsToRemove += $installDir
        }
    }
    
    if ($persistenceaiCmd) {
        $binDir = Split-Path $persistenceaiCmd.Source -Parent
        $installDir = Split-Path $binDir -Parent
        if ($installDir -and $installDir -notin $dirsToRemove) {
            $dirsToRemove += $installDir
        }
    }
    
    foreach ($dir in $dirsToRemove) {
        if (Test-Path $dir) {
            Write-Info "Removing $dir..."
            $maxRetries = 3
            
            for ($i = 1; $i -le $maxRetries; $i++) {
                try {
                    Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
                    break
                } catch {
                    if ($i -lt $maxRetries) {
                        Write-Warning "Attempt $i failed, retrying in 2 seconds..."
                        Start-Sleep -Seconds 2
                    } else {
                        Write-Warning "Could not remove $dir after $maxRetries attempts"
                        Write-Info "Files may be locked. Try running the standalone uninstall.ps1 script or restart your computer."
                    }
                }
            }
        }
    }
    
    # Clean PATH
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath) {
        $newUserPath = ($userPath -split ";" | Where-Object { 
            $_ -and $_ -notmatch "\.persistenceai" -and $_ -notmatch "\.pai" 
        }) -join ";"
        [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
    }
    
    # Update current session PATH
    $env:Path = ($env:Path -split ";" | Where-Object { 
        $_ -and $_ -notmatch "\.persistenceai" -and $_ -notmatch "\.pai" 
    }) -join ";"
    
    Write-Success "PersistenceAI uninstalled successfully"
}

# ============================================================================
# Installation Method Detection (for uninstall)
# ============================================================================

function Get-InstallMethod {
    $binaryPath = Get-Command -Name $APP_NAME -ErrorAction SilentlyContinue
    if ($binaryPath) {
        $installDir = Split-Path $binaryPath.Source -Parent
        if ($installDir -like "*\.persistenceai\bin*") {
            return "curl"  # Installed via this script
        }
    }
    return "unknown"
}

# ============================================================================
# Main Installation Flow
# ============================================================================

# Create directories
Write-Step "Preparing installation directories..."
New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null

if (Test-Path $TEMP_DIR) {
    Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force -Path $TEMP_DIR | Out-Null

# Download
$zipPath = Join-Path $TEMP_DIR $zipName
if (-not (Get-Binary -Url $downloadUrl -OutputPath $zipPath)) {
    Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Extract
Write-Step "Extracting archive..."
try {
    Expand-Archive -Path $zipPath -DestinationPath $TEMP_DIR -Force
    
    # Find executables
    $exePath = Join-Path $TEMP_DIR "bin\$APP_NAME.exe"
    if (-not (Test-Path $exePath)) {
        $exePath = Join-Path $TEMP_DIR "$APP_NAME.exe"
    }
    
    $paiExePath = Join-Path $TEMP_DIR "bin\pai.exe"
    if (-not (Test-Path $paiExePath)) {
        $paiExePath = Join-Path $TEMP_DIR "pai.exe"
    }
    
    if (-not (Test-Path $exePath) -and -not (Test-Path $paiExePath)) {
        throw "Executable not found in archive"
    }
} catch {
    Write-Error "Extraction failed: $_"
    Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Install binaries
if (Test-Path $exePath) {
    $targetPath = Join-Path $INSTALL_DIR "$APP_NAME.exe"
    if (-not (Install-Binary -SourcePath $exePath -TargetPath $targetPath)) {
        Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }
}

if (Test-Path $paiExePath) {
    $paiTargetPath = Join-Path $INSTALL_DIR "pai.exe"
    if (-not (Install-Binary -SourcePath $paiExePath -TargetPath $paiTargetPath)) {
        Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }
} elseif (Test-Path $exePath) {
    # Create pai.exe as a copy if it doesn't exist
    $paiTargetPath = Join-Path $INSTALL_DIR "pai.exe"
    Copy-Item -Path $exePath -Destination $paiTargetPath -Force
    Write-Success "Created 'pai' command (alias)"
}

# Verify installation
Write-Step "Verifying installation..."
$exeFullPath = Join-Path $INSTALL_DIR "$APP_NAME.exe"
$paiExeFullPath = Join-Path $INSTALL_DIR "pai.exe"

if (-not (Test-Path $exeFullPath) -or -not (Test-Path $paiExeFullPath)) {
    Write-Error "Installation verification failed"
    Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

try {
    $versionOutput = & $exeFullPath --version 2>&1 | Select-Object -First 1
    Write-Success "Installed version: $versionOutput"
    
    # Debug: Show final file modification times
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "Debug Information:" -ForegroundColor Cyan
    if (Test-Path $exeFullPath) {
        $finalFile = Get-Item $exeFullPath
        $finalModTime = $finalFile.LastWriteTime
        $timeSinceFinal = (Get-Date) - $finalModTime
        Write-Info "persistenceai.exe last modified: $finalModTime ($([math]::Round($timeSinceFinal.TotalMinutes, 2)) minutes ago)"
    }
    if (Test-Path $paiExeFullPath) {
        $finalPaiFile = Get-Item $paiExeFullPath
        $finalPaiModTime = $finalPaiFile.LastWriteTime
        $timeSinceFinalPai = (Get-Date) - $finalPaiModTime
        Write-Info "pai.exe last modified: $finalPaiModTime ($([math]::Round($timeSinceFinalPai.TotalMinutes, 2)) minutes ago)"
    }
    Write-Host ""
} catch {
    Write-Warning "Could not verify version"
}

# Update PATH
Update-Path -InstallDir $INSTALL_DIR

# Cleanup
Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue

# Success message
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "================================" -ForegroundColor DarkGray
Write-Host "  " -NoNewline; Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "  " -NoNewline; Write-Host "================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "Location:" -ForegroundColor Cyan -NoNewline; Write-Host " $INSTALL_DIR" -ForegroundColor Gray
Write-Host "  " -NoNewline; Write-Host "Commands:" -ForegroundColor Cyan -NoNewline; Write-Host " persistenceai, pai" -ForegroundColor Gray
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "Note:" -ForegroundColor Yellow -NoNewline; Write-Host " Restart PowerShell for PATH changes to take effect" -ForegroundColor Gray
Write-Host ""
