# Initialize RooFlow
# This script automates the process of setting up RooFlow in a project
# It is designed to be triggered when a user tells Roo "Initialize RooFlow"

function Initialize-RooFlow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ProjectPath = (Get-Location).Path
    )

    Write-Host "Initializing RooFlow in: $ProjectPath" -ForegroundColor Green

    # Step 1: Check if the project directory exists
    if (-not (Test-Path -Path $ProjectPath -PathType Container)) {
        Write-Error "The specified project path does not exist: $ProjectPath"
        return $false
    }

    # Navigate to the project directory
    Push-Location $ProjectPath

    try {
        # Step 2: Create .roo directory if it doesn't exist
        if (-not (Test-Path -Path ".roo")) {
            Write-Host "Creating .roo directory..." -ForegroundColor Yellow
            New-Item -Path ".roo" -ItemType Directory | Out-Null
            Write-Host "Created .roo directory" -ForegroundColor Green
        } else {
            Write-Host ".roo directory already exists" -ForegroundColor Yellow
        }

        # Step 3: Create .roomodes file if it doesn't exist
        if (-not (Test-Path -Path ".roomodes")) {
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
        } else {
            Write-Host ".roomodes file already exists" -ForegroundColor Yellow
        }

        # Step 4: Create .rooignore file if it doesn't exist
        if (-not (Test-Path -Path ".rooignore")) {
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
        } else {
            Write-Host ".rooignore file already exists" -ForegroundColor Yellow
        }

        # Step 5: Create memory-bank directory if it doesn't exist
        if (-not (Test-Path -Path "memory-bank")) {
            Write-Host "Creating memory-bank directory..." -ForegroundColor Yellow
            New-Item -Path "memory-bank" -ItemType Directory | Out-Null
            Write-Host "Created memory-bank directory" -ForegroundColor Green
        } else {
            Write-Host "memory-bank directory already exists" -ForegroundColor Yellow
        }

        # Get current timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        # Get project name from directory
        $projectName = Split-Path -Path $ProjectPath -Leaf

        # Step 6: Create memory bank files if they don't exist
        $memoryBankFiles = @{
            "productContext.md" = @"
# Product Context

## Project Overview
[Brief description of $projectName]

## Goals
- [Goal 1]
- [Goal 2]

## Features
- [Feature 1]
- [Feature 2]

## Architecture
[High-level architecture description]
"@
            "activeContext.md" = @"
# Active Context

## Current Focus
[Current focus of development]

## Recent Changes
RooFlow memory bank initialized on $timestamp

## Open Questions/Issues
[Open questions or issues]
"@
            "systemPatterns.md" = @"
# System Patterns

## Design Patterns
[Design patterns used in the project]

## Architectural Patterns
[Architectural patterns used in the project]

## Coding Standards
[Coding standards followed in the project]
"@
            "decisionLog.md" = @"
# Decision Log

[$timestamp] - RooFlow memory bank initialized
"@
            "progress.md" = @"
# Progress

[$timestamp] - RooFlow memory bank initialized
"@
        }

        foreach ($file in $memoryBankFiles.Keys) {
            $filePath = "memory-bank/$file"
            if (-not (Test-Path -Path $filePath)) {
                Write-Host "Creating $filePath..." -ForegroundColor Yellow
                Set-Content -Path $filePath -Value $memoryBankFiles[$file]
                Write-Host "Created $filePath" -ForegroundColor Green
            } else {
                Write-Host "$filePath already exists" -ForegroundColor Yellow
            }
        }

        # Step 7: Copy system prompt files to .roo directory
        $systemPromptFiles = @(
            "system-prompt-architect",
            "system-prompt-ask",
            "system-prompt-code",
            "system-prompt-debug",
            "system-prompt-test"
        )

        # Source directory for system prompt files
        $sourceDir = "$PSScriptRoot\system-prompts"

        foreach ($file in $systemPromptFiles) {
            $sourcePath = "$sourceDir\$file"
            $destPath = ".roo\$file"
            
            if (Test-Path -Path $sourcePath) {
                if (-not (Test-Path -Path $destPath)) {
                    Write-Host "Copying $file to .roo directory..." -ForegroundColor Yellow
                    Copy-Item -Path $sourcePath -Destination $destPath
                    Write-Host "Copied $file to .roo directory" -ForegroundColor Green
                } else {
                    Write-Host "$destPath already exists" -ForegroundColor Yellow
                }
            } else {
                Write-Error "Source file not found: $sourcePath"
                return $false
            }
        }

        # Step 8: Run insert-variables script to replace placeholders
        Write-Host "Replacing placeholders in system prompt files..." -ForegroundColor Yellow

        # Get Environment Variables
        $os = (Get-CimInstance Win32_OperatingSystem).Caption
        $shell = "powershell"
        $homeDir = $env:USERPROFILE
        $workspace = $ProjectPath
        $globalSettings = "$env:APPDATA\Code\User\globalStorage\rooveterinaryinc.roo-cline\settings\cline_custom_modes.json"
        $mcpLocation = "$env:USERPROFILE\.local\share\Roo-Code\MCP"
        $mcpSettings = "$env:APPDATA\Code\User\globalStorage\rooveterinaryinc.roo-cline\settings\cline_mcp_settings.json"

        # Process each system prompt file
        $rooDir = ".roo"
        $files = Get-ChildItem -Path $rooDir -Filter "system-prompt-*"
        
        foreach ($file in $files) {
            Write-Host "Processing: $($file.FullName)" -ForegroundColor Yellow
            $content = Get-Content $file.FullName -Raw
            $content = $content -replace 'OS_PLACEHOLDER', $os
            $content = $content -replace 'SHELL_PLACEHOLDER', $shell
            $content = $content -replace 'HOME_PLACEHOLDER', $homeDir
            $content = $content -replace 'WORKSPACE_PLACEHOLDER', $workspace
            $content = $content -replace 'GLOBAL_SETTINGS_PLACEHOLDER', $globalSettings
            $content = $content -replace 'MCP_LOCATION_PLACEHOLDER', $mcpLocation
            $content = $content -replace 'MCP_SETTINGS_PLACEHOLDER', $mcpSettings
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "Completed: $($file.FullName)" -ForegroundColor Green
        }

        Write-Host "`nRooFlow has been successfully initialized in the project!" -ForegroundColor Green
        Write-Host "`nNext steps:" -ForegroundColor Cyan
        Write-Host "1. Start a new Roo Code task in Architect mode" -ForegroundColor Cyan
        Write-Host "2. Roo will detect the memory bank and activate it" -ForegroundColor Cyan
        Write-Host "3. Begin with a project planning session to populate the memory bank" -ForegroundColor Cyan
        Write-Host "4. Use 'Update Memory Bank' or 'UMB' command at key milestones" -ForegroundColor Cyan

        return $true
    }
    catch {
        Write-Error "An error occurred: $_"
        return $false
    }
    finally {
        # Return to the original directory
        Pop-Location
    }
}

# Execute the function if the script is run directly
if ($MyInvocation.InvocationName -ne ".") {
    Initialize-RooFlow
}