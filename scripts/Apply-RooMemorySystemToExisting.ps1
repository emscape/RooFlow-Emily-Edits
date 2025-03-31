<#
.SYNOPSIS
Applies the memory bank optimization and archiving system to an existing project directory.

.DESCRIPTION
This script ensures the necessary directories and configuration files for the Roo Memory System
exist in a specified existing project path. It checks for existing structures and creates missing
components without overwriting existing memory bank data. It prepares the project for the
optimization and archiving features.

.PARAMETER ProjectPath
The root path of the existing project where the memory system should be applied.

.EXAMPLE
.\scripts\Apply-RooMemorySystemToExisting.ps1 -ProjectPath "C:\path\to\existing\project"

.NOTES
Author: Roo
Date: 2025-03-29
Future versions will integrate migration tools for analyzing and tagging existing memory bank entries.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

Write-Host "Applying Roo Memory System to existing project '$ProjectPath'..."

# Define paths relative to the project path
$memoryBankPath = Join-Path -Path $ProjectPath -ChildPath "memory-bank"
$archivesSubPath = Join-Path -Path $memoryBankPath -ChildPath "archives"
$memoryArchivesPath = Join-Path -Path $ProjectPath -ChildPath "memory-archives"
$configFilePath = Join-Path -Path $memoryBankPath -ChildPath "memory-config.json"
$archiveIndexFilePath = Join-Path -Path $archivesSubPath -ChildPath "archive-index.md"

$rooDirPath = Join-Path -Path $ProjectPath -ChildPath ".roo"
$mcpConfigPath = Join-Path -Path $ProjectPath -ChildPath "mcp-config.json" # MCP config at project root

# List of archive files to check/create
$archiveFiles = @(
    "activeContext-archive.md",
    "decisionLog-archive.md",
    "productContext-archive.md",
    "progress-archive.md",
    "systemPatterns-archive.md"
)

# --- Pre-checks ---
if (-not (Test-Path -Path $memoryBankPath -PathType Container)) {
    Write-Error "The memory-bank directory does not exist in '$ProjectPath'. This script requires an existing memory bank."
    # Consider adding logic to initialize if desired, but current plan assumes existing memory bank.
    return
}

# --- Directory Creation (if missing) ---

# Create memory-bank/archives directory if missing
if (-not (Test-Path -Path $archivesSubPath -PathType Container)) {
    Write-Host "Creating memory-bank archives subdirectory: $archivesSubPath"
    New-Item -Path $archivesSubPath -ItemType Directory -Force | Out-Null
} else {
    Write-Host "Memory-bank archives subdirectory already exists: $archivesSubPath"
}

# Create memory-archives directory if missing
if (-not (Test-Path -Path $memoryArchivesPath -PathType Container)) {
    Write-Host "Creating memory-archives directory: $memoryArchivesPath"
    New-Item -Path $memoryArchivesPath -ItemType Directory -Force | Out-Null
} else {
    Write-Host "Memory-archives directory already exists: $memoryArchivesPath"
}

# Create .roo directory if missing
if (-not (Test-Path -Path $rooDirPath -PathType Container)) {
    Write-Host "Creating .roo directory: $rooDirPath"
    New-Item -Path $rooDirPath -ItemType Directory -Force | Out-Null
} else {
    Write-Host ".roo directory already exists: $rooDirPath"
}


# --- File Creation (if missing) ---

# Create memory-config.json with default content if missing
if (-not (Test-Path -Path $configFilePath -PathType Leaf)) {
    Write-Host "Creating default memory-config.json: $configFilePath"
    $defaultConfig = @{
        activeProjects = @() # Existing projects might need manual population later
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
        projectMetadata = @{} # Existing projects might need analysis/migration later
    } | ConvertTo-Json -Depth 5
    Set-Content -Path $configFilePath -Value $defaultConfig
} else {
    Write-Host "memory-config.json already exists: $configFilePath"
    # TODO: Consider checking/updating schema if needed in future versions
}

# Create empty archive files if missing
foreach ($file in $archiveFiles) {
    $filePath = Join-Path -Path $archivesSubPath -ChildPath $file
    if (-not (Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "Creating empty archive file: $filePath"
        New-Item -Path $filePath -ItemType File -Force | Out-Null
    } else {
        Write-Host "Archive file already exists: $filePath"
    }
}

# Create empty archive-index.md if missing
if (-not (Test-Path -Path $archiveIndexFilePath -PathType Leaf)) {
    Write-Host "Creating empty archive index: $archiveIndexFilePath"
    New-Item -Path $archiveIndexFilePath -ItemType File -Force | Out-Null
} else {
    Write-Host "Archive index already exists: $archiveIndexFilePath"
}

# Create mcp-config.json with default server configurations if missing
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


# --- Future Migration Steps Placeholder ---
Write-Host "Initial structure check/creation complete."
Write-Host "TODO: Integrate migration tools for analysis and retroactive tagging of existing memory bank entries."

# TODO: Optionally copy memory-manager.ps1 if it's a standalone tool and missing

Write-Host "Roo Memory System application complete for '$ProjectPath'."