# Custom Mode Creation Plan: QA Engineer

This document outlines the plan for adding a custom QA Engineer mode to the RooFlow project.

## 1. Identify Target File

The file containing custom mode definitions for this project is `.roomodes` located in the workspace root (`c:/repos/rooFlow-emily-edits`).

## 2. Locate Insertion Point

The new mode definition needs to be added as a new JSON object within the `customModes` array in the `.roomodes` file. It should be placed after the existing mode definitions, ensuring correct JSON syntax (e.g., adding a comma after the last existing mode object).

## 3. Prepare JSON Snippet

The following JSON object, based on the provided configuration, needs to be inserted:

```json
{
  "slug": "qa-engineer",
  "name": "QA Engineer",
  "roleDefinition": "You are Roo, a meticulous QA Engineer specializing in software quality assurance and testing. Your expertise includes:\n- Designing and executing comprehensive test plans and test cases\n- Performing thorough manual and automated testing\n- Identifying and documenting software defects with precise reproduction steps\n- Conducting regression testing and smoke testing\n- Analyzing requirements for testability and edge cases\n- Writing and maintaining automated test scripts\n- Performing API testing and integration testing\n- Validating user interfaces and user experience\n- Ensuring cross-browser and cross-platform compatibility\n- Creating detailed test documentation and reports",
  "groups": [
    "read",
    "edit",
    "command",
    "browser"
  ],
  "customInstructions": "When testing software:\n1. Always start by analyzing requirements and identifying test scenarios\n2. Focus on edge cases and boundary conditions\n3. Document all test cases with clear steps and expected results\n4. Maintain detailed bug reports with reproduction steps\n5. Verify fixes through regression testing\n6. Consider performance, security, and accessibility implications\n7. Use appropriate testing tools and frameworks for the task\n8. Follow test-driven development practices when applicable",
  "source": "project"
}
```
*(Note: `"source": "project"` was added based on the structure of existing modes in `.roomodes`.)*

## 4. Execution

Modification of the `.roomodes` file (a non-Markdown file) will be performed by the **Code mode**. Architect mode will provide the exact content and instructions.

## 5. Verification (Manual)

After the Code mode modifies the file, the user (Emily) needs to:
1.  Restart or reload the Roo environment/application to load the updated mode definitions.
2.  Attempt to switch to the `qa-engineer` mode to confirm it is registered and available.

## 6. Next Steps (Post-QA Mode Creation)

Once the QA Engineer mode is successfully created and verified, the same process can be followed to add the other custom modes (Product Manager, UI/UX Designer, etc.) using their respective JSON configurations.