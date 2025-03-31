# Plan: Create MCP Configuration Automation Script

This plan outlines the development of a PowerShell script to automate the configuration of MCP servers defined in `.roo/mcp-config.json`.

1.  **Goal:** Develop a PowerShell script named `Configure-McpServers.ps1` that interactively guides the user through enabling MCP servers and defining their allowed tools within the `.roo/mcp-config.json` file.
2.  **Location:** The new script will be created in the `scripts/` directory.
3.  **Script Functionality:**
    *   **Load Configuration:** Read the `.roo/mcp-config.json` file. Handle errors if the file doesn't exist or contains invalid JSON.
    *   **Server Iteration:** Loop through each server defined in the configuration (e.g., "filesystem", "git", "braveSearch").
    *   **Interactive Enablement:** For each server:
        *   Display its name and current status (enabled/disabled).
        *   Prompt the user if they want to enable this server (Y/N).
    *   **Tool Permission Configuration (If Enabled):**
        *   If the user chooses to enable a server:
            *   Set `"enabled": true`.
            *   Identify the server type based on its key name ("filesystem", "git", "braveSearch").
            *   List the tools available for that specific server type (as identified from `McpHandler.psm1`).
            *   Prompt the user individually for each available tool: "Allow tool '\[ToolName]'? (y/n)".
            *   Build the `allowedTools` array based on 'y' responses.
            *   Update the server's configuration in the loaded JSON object with `"enabled": true` and the constructed `"allowedTools": [...]` array.
        *   If the user chooses *not* to enable a server:
            *   Ensure `"enabled": false` is set in the configuration object.
    *   **Save Configuration:** After iterating through all servers, write the modified configuration object back to `.roo/mcp-config.json`, overwriting the existing file.
    *   **Environment Variable Reminders:**
        *   Scan the final configuration.
        *   If the `git` server is enabled and its configuration specifies a `credentialsEnvVar`, display a reminder message for the user to set that environment variable.
        *   If the `braveSearch` server is enabled, display a reminder message for the user to set the `BRAVE_SEARCH_API_KEY` environment variable.
    *   **Error Handling & Feedback:** Implement robust error handling (try/catch) for file I/O and JSON operations, providing clear feedback messages throughout the process.
4.  **Documentation:** Include comments within the `Configure-McpServers.ps1` script explaining its logic.
5.  **Next Steps:** Switch to Code mode to implement the script.

## Visual Plan (Flowchart)

```mermaid
graph TD
    A[Start Configure-McpServers.ps1] --> B{Read .roo/mcp-config.json};
    B -- Success --> C{Iterate Through Servers};
    B -- Failure --> Z[Error: Cannot Read Config];
    C -- For Each Server --> D{Display Server Status};
    D --> E{Enable Server? (Y/N)};
    E -- Yes --> F{Set enabled=true};
    F --> G{Identify Server Type};
    G --> H{List Available Tools for Type};
    H --> I{For Each Tool: Allow? (Y/N)};
    I -- User Selections --> J{Update allowedTools Array};
    J --> K{Next Server / End Loop};
    E -- No --> L{Set enabled=false};
    L --> K;
    C -- End Loop --> M{Write Updated .roo/mcp-config.json};
    M -- Success --> N{Check Enabled Servers for Env Vars};
    M -- Failure --> Y[Error: Cannot Write Config];
    N --> O{Git Enabled & Needs Env Var?};
    O -- Yes --> P[Remind User: Git Env Var];
    O -- No --> Q;
    P --> Q;
    N --> Q{Brave Search Enabled?};
    Q -- Yes --> R[Remind User: Brave API Key Env Var];
    Q -- No --> S[End Script];
    R --> S;
    Z --> T[Exit];
    Y --> T;
    S --> T;