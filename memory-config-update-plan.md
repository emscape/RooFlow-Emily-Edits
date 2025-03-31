# Plan: Update Memory Configuration Handling

**Goal:** Resolve errors caused by a mismatch between the `memory-config.json` structure created by `Setup-RooProject.ps1` and the structure expected by `memory-manager.ps1`.

**Analysis:**
- `Setup-RooProject.ps1` currently creates a `memory-config.json` with keys: `projectName`, `status`, `archival`, `tags`.
- `memory-manager.ps1` expects keys: `activeProjects`, `completedProjects`, `archiveSettings`, `loadSettings`, `projectMetadata`.
- The existing `memory-bank/memory-config.json` also has `"activeProjects"` as a string instead of an array.

**Steps:**

1.  **Modify `scripts/Setup-RooProject.ps1`:**
    *   Replace the `$DefaultMemoryConfigContent` block (around lines 101-115) with the following PowerShell code to ensure new projects get the correct structure:
        ```powershell
        # 2. Ensure Memory Bank Config File Exists
        $MemoryConfigFilePath = Join-Path -Path $MemoryBankPath -ChildPath "memory-config.json"
        # Updated default content to match memory-manager.ps1 expectations
        $DefaultMemoryConfigContent = @"
        {
          "activeProjects": [],
          "completedProjects": [],
          "archiveSettings": {
            "autoArchiveCompleted": false,
            "keepCompletedDays": 30,
            "archiveOnUMB": false
          },
          "loadSettings": {
            "prioritizeActive": true,
            "maxEntriesPerFile": 100,
            "loadCompletedProjects": false
          },
          "projectMetadata": {}
        }
        "@
        Ensure-FileExists -Path $MemoryConfigFilePath -DefaultContent $DefaultMemoryConfigContent
        ```

2.  **Modify `memory-bank/memory-config.json`:**
    *   Change line 2 from:
        `"activeProjects": "ProjectAlpha",`
    *   To:
        `"activeProjects": ["ProjectAlpha"],`
    *   This corrects the format in the existing configuration file.

**Next Action:**
- Switch to Code mode to implement these changes.