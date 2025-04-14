# Decision Log

This file tracks important decisions made during project development.

## Usage Guidelines

- Use `<!-- @active -->` tags for currently relevant decisions
- Use `<!-- @project:ProjectName -->` tags to associate decisions with specific projects
- Use `<!-- @completed -->` tags for decisions that have been fully implemented or are no longer relevant

## Decision Entries

<!-- @active -->
[2025-03-26 14:20:00] - Decision to implement Memory Bank Optimization System with relevance-based tagging
<!-- @end -->



<!-- @active -->
[2025-03-29 19:16:00] - Finalized plan (v4) for MCP Server Integration into RooFlow. Key aspects include:
    - Initial Targets: Filesystem, Git, Brave Search servers.
    - Architecture: `mcp-config.json` for configuration, REST/HTTPS communication.
    - Security: Mandatory env var auth, secure defaults (`enabled: false`, `alwaysAllow: []`), HTTPS, scope limits.
    - Testing: Unit, Integration (mocks/test instances), basic Security checks.
    - Orchestration: Boomerang Mode will manage implementation, testing, and documentation phases by delegating to specialized modes (Code, Test, Ask).
    - Plan saved to `mcp-integration-plan.md`.
<!-- @end -->


<!-- @active -->
[2025-03-30 21:38:00] - Requirement identified: Enhance the initial Memory Bank check process (memory_bank_strategy) to automatically verify if essential configurations (like MCP) are present and potentially run setup scripts (e.g., Apply-RooMemorySystemToExisting.ps1 with correct parameters) if configurations are missing or incomplete. This aims to prevent manual script execution errors and ensure the system is ready for use upon activation.


<!-- @active -->
[2025-03-30 21:49:00] - Decision: Create an interactive PowerShell script (`Configure-McpServers.ps1`) to automate enabling/disabling MCP servers and configuring their `allowedTools` in `.roo/mcp-config.json`. Plan saved to `mcp-configuration-automation-plan.md`.
<!-- @end -->
<!-- @end -->
