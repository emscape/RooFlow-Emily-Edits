# Plan: Incorporating MCP Servers into RooFlow (v4)

This plan outlines the steps to integrate Model Context Protocol (MCP) servers into the RooFlow ecosystem, enabling extended capabilities through external tools and resources. The implementation will be orchestrated by Boomerang Mode, delegating tasks to specialized modes (Code, Test, Ask).

**Initial Target Servers:**

*   **Filesystem Server:** Controlled local filesystem access.
*   **Git Server:** Interaction with Git repositories (e.g., GitHub API or local Git wrapper).
*   **Brave Search Server:** Web search via Brave Search API.

**Phase 1: Design and Architecture (Architect Mode - Completed)**

1.  **Define MCP Server Purpose & Initial Targets:** Documented general purpose and target servers.
2.  **Architectural Integration:** Defined communication (REST/HTTPS), config storage (`mcp-config.json` in `.roo` or `config`), and authentication.
3.  **Security Design:** Mandated env var auth, secure defaults (`enabled: false`, `alwaysAllow: []`), HTTPS, input sanitization needs, scope limitation (`allowedTools`/`allowedResources`).
4.  **Configuration Schema:** Defined JSON schema for `mcp-config.json`.

**Phase 2: Implementation (Orchestrated by Boomerang Mode)**

5.  **Workflow Orchestration (Boomerang Mode):** Break down implementation into subtasks delegated via `new_task` to Code/Test Modes.
6.  **Setup Script Modifications (Code Mode Subtask):**
    *   Update `Initialize-RooMemorySystem.ps1` to create `mcp-config.json` with secure defaults and commented-out examples.
    *   Update `Apply-RooMemorySystemToExisting.ps1` similarly.
7.  **Core RooFlow Agent Changes (Code Mode Subtask):**
    *   Implement logic for config reading, security enforcement, credential handling, communication, error management, and I/O sanitization for target servers.

**Phase 3: Testing (Orchestrated by Boomerang Mode)**

8.  **Workflow Orchestration (Boomerang Mode):** Delegate testing tasks via `new_task` to Test Mode.
9.  **Unit Testing (Test Mode Subtask):** Create unit tests for config parsing, credential fetching, request/response handling, etc.
10. **Integration Testing (Test Mode Subtask):** Create integration tests (mocks/test instances) for Filesystem, Git, Brave Search, verifying security.
11. **Security Testing (Test Mode Subtask):** Perform basic security checks (credential logging, defaults, input validation).

**Phase 4: Documentation & Finalization (Orchestrated by Boomerang Mode)**

12. **Workflow Orchestration (Boomerang Mode):** Delegate documentation via `new_task` to Ask/Code Mode.
13. **Documentation Updates (Ask/Code Mode Subtask):**
    *   Update `README.md`.
    *   Create/update `docs/mcp-integration.md` (Security, Testing, specific examples for Filesystem, Git, Brave Search, Boomerang orchestration).
    *   Update script docs.
14. **Memory Bank Update (Architect/Code Mode Subtask):**
    *   Log final plan details in `memory-bank/decisionLog.md`.

**Diagram: High-Level MCP Integration**

```mermaid
graph TD
    A[Roo Agent] -- Reads --> C{mcp-config.json};
    C -- Defines --> S1[MCP Server 1 (e.g., Filesystem)];
    C -- Defines --> S2[MCP Server 2 (e.g., Git)];
    C -- Defines --> S3[MCP Server 3 (e.g., Brave Search)];
    A -- Uses Tool/Resource --> M1[use_mcp_tool / access_mcp_resource];
    M1 -- Reads Env Var --> E{Environment Variable (Credential)};
    M1 -- Sends Request (with Auth) --> S1;
    M1 -- Sends Request (with Auth) --> S2;
    M1 -- Sends Request (with Auth) --> S3;
    S1 -- Provides --> T1[Tool/Resource];
    S2 -- Provides --> T2[Tool/Resource];
    S3 -- Provides --> T3[Tool/Resource];
    T1 -- Returns Result --> A;
    T2 -- Returns Result --> A;
    T3 -- Returns Result --> A;

    INIT[Initialize-RooMemorySystem.ps1] -- Creates --> C;
    APPLY[Apply-RooMemorySystemToExisting.ps1] -- Creates/Checks --> C;