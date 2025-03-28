# Setup New Project with RooFlow Custom Modes
# This script automates the process of creating a new project with RooFlow custom modes
# Usage: .\setup-new-project.ps1 -ProjectName "YourProjectName" -ProjectPath "C:\path\to\parent\directory"

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = (Get-Location).Path
)

# Construct the full project path
$fullProjectPath = Join-Path -Path $ProjectPath -ChildPath $ProjectName

# Check if the project directory already exists
if (Test-Path -Path $fullProjectPath -PathType Container) {
    Write-Error "A directory with the name '$ProjectName' already exists at '$ProjectPath'"
    exit 1
}

# Create the project directory
Write-Host "Creating new project: $ProjectName at $fullProjectPath" -ForegroundColor Green
New-Item -Path $fullProjectPath -ItemType Directory | Out-Null

# Navigate to the project directory
Push-Location $fullProjectPath

try {
    # Step 1: Initialize Git repository
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init | Out-Null
    Write-Host "Git repository initialized" -ForegroundColor Green

    # Step 2: Create .roomodes file
    Write-Host "Creating .roomodes file..." -ForegroundColor Yellow
    $roomodesContent = @'
{
  "customModes": [
    {
      "slug": "test",
      "name": "Test",
      "roleDefinition": "You are Roo's Test mode for this specific project",
      "groups": [
        "read",
        "browser",
        "command",
        "edit",
        "mcp"
      ],
      "source": "project",
      "customInstructions": "Always check to make sure memory bank is active. Explicitly prompt Emily when she needs to do a manual action. terminal commands must be PowerShell. Explicitly prompt Emily when she needs to do a manual action. Save to memory and prompt user to start a new task when token cost nears $0.5"
    }
  ]
}
'@
    Set-Content -Path ".roomodes" -Value $roomodesContent
    Write-Host "Created .roomodes file" -ForegroundColor Green

    # Step 3: Create .rooignore file
    Write-Host "Creating .rooignore file..." -ForegroundColor Yellow
    $rooignoreContent = @'
node_modules/
dist/
build/
.git/
*.log
'@
    Set-Content -Path ".rooignore" -Value $rooignoreContent
    Write-Host "Created .rooignore file" -ForegroundColor Green

    # Step 4: Create .gitignore file
    Write-Host "Creating .gitignore file..." -ForegroundColor Yellow
    $gitignoreContent = @'
# Dependency directories
node_modules/
jspm_packages/

# Build outputs
dist/
build/
out/
*.min.*

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
lib-cov

# Coverage directory used by tools like istanbul
coverage

# nyc test coverage
.nyc_output

# IDEs and editors
.idea/
.vscode/
*.swp
*.swo
*~
.DS_Store
'@
    Set-Content -Path ".gitignore" -Value $gitignoreContent
    Write-Host "Created .gitignore file" -ForegroundColor Green

    # Step 5: Create memory-bank directory
    Write-Host "Creating memory-bank directory..." -ForegroundColor Yellow
    New-Item -Path "memory-bank" -ItemType Directory | Out-Null
    Write-Host "Created memory-bank directory" -ForegroundColor Green

    # Get current timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Step 6: Create memory bank files
    $memoryBankFiles = @{
        "productContext.md" = @"
# Product Context

## Project Overview
[Brief description of $ProjectName]

## Goals
- [Primary goal]
- [Secondary goal]

## Features
- [Core feature 1]
- [Core feature 2]

## Architecture
[Initial architecture decisions]
"@
        "activeContext.md" = @"
# Active Context

## Current Focus
Initial project setup and planning

## Recent Changes
Project initialization on $timestamp

## Open Questions/Issues
- [Initial question/issue 1]
- [Initial question/issue 2]
"@
        "systemPatterns.md" = @"
# System Patterns

## Design Patterns
[Initial design patterns]

## Architectural Patterns
[Initial architectural patterns]

## Coding Standards
[Project-specific coding standards]
"@
        "decisionLog.md" = @"
# Decision Log

[$timestamp] - Project initialized with RooFlow memory bank
"@
        "progress.md" = @"
# Progress

[$timestamp] - Project setup with RooFlow memory bank
"@
    }

    foreach ($file in $memoryBankFiles.Keys) {
        Write-Host "Creating memory-bank/$file..." -ForegroundColor Yellow
        Set-Content -Path "memory-bank/$file" -Value $memoryBankFiles[$file]
        Write-Host "Created memory-bank/$file" -ForegroundColor Green
    }

    # Step 7: Create a basic README.md
    Write-Host "Creating README.md..." -ForegroundColor Yellow
    $readmeContent = @"
# $ProjectName

## Overview
[Brief description of the project]

## Getting Started
[Instructions for setting up and running the project]

## Features
[List of features]

## Contributing
[Guidelines for contributing to the project]

## License
[License information]
"@
    Set-Content -Path "README.md" -Value $readmeContent
    Write-Host "Created README.md" -ForegroundColor Green

    # Step 8: Create a basic project structure (example for a web project)
    Write-Host "Creating basic project structure..." -ForegroundColor Yellow
    New-Item -Path "src" -ItemType Directory | Out-Null
    New-Item -Path "docs" -ItemType Directory | Out-Null
    New-Item -Path "tests" -ItemType Directory | Out-Null
    Write-Host "Created basic project structure" -ForegroundColor Green

    Write-Host "`nNew project '$ProjectName' has been successfully set up with RooFlow custom modes!" -ForegroundColor Green
    Write-Host "`nProject location: $fullProjectPath" -ForegroundColor Green
    
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "1. Open the project in VS Code: code '$fullProjectPath'" -ForegroundColor Cyan
    Write-Host "2. Start a new Roo Code task in Architect mode" -ForegroundColor Cyan
    Write-Host "3. Begin with a project planning session" -ForegroundColor Cyan
    Write-Host "4. Use 'Update Memory Bank' or 'UMB' command at key milestones" -ForegroundColor Cyan

} catch {
    Write-Error "An error occurred: $_"
} finally {
    # Return to the original directory
    Pop-Location
}