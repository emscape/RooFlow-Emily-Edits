<#
.SYNOPSIS
Sets up the memory bank optimization and archiving system in a new project directory.

.DESCRIPTION
This script creates the necessary directories and configuration files for the Roo Memory System
in a specified new project path. It initializes the archive structure and configuration.

.PARAMETER ProjectPath
The root path of the new project where the memory system should be initialized.

.EXAMPLE
.\scripts\Initialize-RooMemorySystem.ps1 -ProjectPath "C:\path\to\new\project"

.NOTES
Author: Roo
Date: 2025-03-29
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

Write-Host "Initializing Roo Memory System in '$ProjectPath'..."

# Define paths relative to the project path
$memoryBankPath = Join-Path -Path $ProjectPath -ChildPath "memory-bank"
$archivesSubPath = Join-Path -Path $memoryBankPath -ChildPath "archives"
$memoryArchivesPath = Join-Path -Path $ProjectPath -ChildPath "memory-archives"
$configFilePath = Join-Path -Path $memoryBankPath -ChildPath "memory-config.json"
$archiveIndexFilePath = Join-Path -Path $archivesSubPath -ChildPath "archive-index.md"

$rooDirPath = Join-Path -Path $ProjectPath -ChildPath ".roo"
$mcpConfigPath = Join-Path -Path $ProjectPath -ChildPath "mcp-config.json" # MCP config at project root
# List of archive files to create
$archiveFiles = @(
    "activeContext-archive.md",
    "decisionLog-archive.md",
    "productContext-archive.md",
    "progress-archive.md",
    "systemPatterns-archive.md"
)

# --- Directory Creation ---

# Ensure memory-bank directory exists (should typically exist if Roo is used)
if (-not (Test-Path -Path $memoryBankPath -PathType Container)) {
    Write-Host "Creating memory-bank directory: $memoryBankPath"
    New-Item -Path $memoryBankPath -ItemType Directory -Force | Out-Null
}

# Create memory-bank/archives directory
if (-not (Test-Path -Path $archivesSubPath -PathType Container)) {
    Write-Host "Creating memory-bank archives subdirectory: $archivesSubPath"
    New-Item -Path $archivesSubPath -ItemType Directory -Force | Out-Null
} else {
    Write-Host "Memory-bank archives subdirectory already exists: $archivesSubPath"
}

# Create memory-archives directory
if (-not (Test-Path -Path $memoryArchivesPath -PathType Container)) {
    Write-Host "Creating memory-archives directory: $memoryArchivesPath"
    New-Item -Path $memoryArchivesPath -ItemType Directory -Force | Out-Null
} else {
    Write-Host "Memory-archives directory already exists: $memoryArchivesPath"
}


# Create .roo directory
if (-not (Test-Path -Path $rooDirPath -PathType Container)) {
    Write-Host "Creating .roo directory: $rooDirPath"
    New-Item -Path $rooDirPath -ItemType Directory -Force | Out-Null
} else {
    Write-Host ".roo directory already exists: $rooDirPath"
}
# --- File Creation ---

# Create memory-config.json with default content
if (-not (Test-Path -Path $configFilePath -PathType Leaf)) {
    Write-Host "Creating default memory-config.json: $configFilePath"
    $defaultConfig = @{
        activeProjects = @()
        completedProjects = @()
        archiveSettings = @{
            autoArchiveCompleted = $true
            keepCompletedDays = 14
            archiveOnUMB = $true
        }
        loadSettings = @{
            prioritizeActive = $true
            maxEntriesPerFile = 50
            loadCompletedProjects = $false
        }
        projectMetadata = @{}
    } | ConvertTo-Json -Depth 5
    Set-Content -Path $configFilePath -Value $defaultConfig
} else {
    Write-Host "memory-config.json already exists: $configFilePath"
}

# Create empty archive files
foreach ($file in $archiveFiles) {
    $filePath = Join-Path -Path $archivesSubPath -ChildPath $file
    if (-not (Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "Creating empty archive file: $filePath"
        New-Item -Path $filePath -ItemType File -Force | Out-Null
    } else {
        Write-Host "Archive file already exists: $filePath"
    }
}

# Create empty archive-index.md
if (-not (Test-Path -Path $archiveIndexFilePath -PathType Leaf)) {
    Write-Host "Creating empty archive index: $archiveIndexFilePath"
    New-Item -Path $archiveIndexFilePath -ItemType File -Force | Out-Null
} else {
    Write-Host "Archive index already exists: $archiveIndexFilePath"
}


# Create mcp-config.json with default server configurations
if (-not (Test-Path -Path $mcpConfigPath -PathType Leaf)) {
    Write-Host "Creating default mcp-config.json: $mcpConfigPath"
    $defaultMcpConfig = @{
        mcpServers = @{
            filesystem = @{
                enabled = $false
                description = "Provides access to the local filesystem."
                basePath = "<Specify base path if needed, e.g., project root or specific data folder>"
            }
            git = @{
                enabled = $false
                description = "Provides Git repository operations."
                repoPath = "<Specify path to the Git repository, defaults to project root if empty>"
                credentialsEnvVar = "<Optional: Environment variable name for Git credentials>"
            }
            braveSearch = @{
                enabled = $false
                description = "Provides web search capabilities via Brave Search API."
                apiKeyEnvVar = "BRAVE_SEARCH_API_KEY" # Placeholder - User must set this environment variable
            }
        }
    } | ConvertTo-Json -Depth 5
    Set-Content -Path $mcpConfigPath -Value $defaultMcpConfig -Encoding UTF8 -Force
} else {
    Write-Host "mcp-config.json already exists: $mcpConfigPath"
}

# --- Custom Modes File Handling ---

# Define path for the source .roomodes file (assuming script runs from repo root or similar structure)
# Adjust this path based on the actual location relative to this script
$sourceRoomodesPath = Join-Path -Path $PSScriptRoot -ChildPath "..\RooCorePackage\.roomodes" 

# Define path for the target .roomodes file in the project
$targetRoomodesPath = Join-Path -Path $ProjectPath -ChildPath ".roomodes"

if (Test-Path -Path $sourceRoomodesPath -PathType Leaf) {
    if (-not (Test-Path -Path $targetRoomodesPath -PathType Leaf)) {
        Write-Host "Copying default .roomodes file to project root: $targetRoomodesPath"
        Copy-Item -Path $sourceRoomodesPath -Destination $targetRoomodesPath -Force
    } else {
        Write-Host ".roomodes file already exists in project: $targetRoomodesPath. Checking for missing modes..."
        try {
            # Read source and target files
            $sourceModesContent = Get-Content -Path $sourceRoomodesPath -Raw | ConvertFrom-Json -ErrorAction Stop
            $targetModesContent = Get-Content -Path $targetRoomodesPath -Raw | ConvertFrom-Json -ErrorAction Stop

            # Check if customModes array exists in both
            if (($null -ne $sourceModesContent) -and ($sourceModesContent.PSObject.Properties.Name -contains 'customModes') -and `
                ($null -ne $targetModesContent) -and ($targetModesContent.PSObject.Properties.Name -contains 'customModes') -and `
                ($sourceModesContent.customModes -is [array]) -and ($targetModesContent.customModes -is [array])) {
                
                $targetSlugs = $targetModesContent.customModes | ForEach-Object { $_.slug }
                $modesToAdd = $sourceModesContent.customModes | Where-Object { $_.slug -notin $targetSlugs }

                if ($modesToAdd.Count -gt 0) {
                    Write-Host "Adding $($modesToAdd.Count) missing modes from the package to the existing .roomodes file..."
                    # Add the new modes to the existing array
                    $updatedModes = $targetModesContent.customModes + $modesToAdd
                    $targetModesContent.customModes = $updatedModes
                    
                    # Save the updated content back to the file
                    $targetModesContent | ConvertTo-Json -Depth 10 | Out-File -FilePath $targetRoomodesPath -Encoding UTF8 -Force
                    Write-Host "Successfully added missing modes."
                } else {
                    Write-Host "No new modes found in the package version to add."
                }
            } else {
                 Write-Warning "Could not compare .roomodes files. Ensure both files are valid JSON and contain a 'customModes' array."
            }
        } catch {
            Write-Error "Failed to read or parse .roomodes files. Error: $($_.Exception.Message)"
        }
    }
} else {
    Write-Warning "Source .roomodes file not found at expected location: $sourceRoomodesPath. Cannot copy or update custom modes."
}


# TODO: Optionally copy memory-manager.ps1 if it's a standalone tool

Write-Host "Roo Memory System initialization complete for '$ProjectPath'."