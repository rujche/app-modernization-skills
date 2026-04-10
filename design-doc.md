## Background

Currently, we have 2 GitHub repositories for app modernization:
- `Extension repo`: https://github.com/devdiv-azure-service-dmitryr/azure-java-migration-copilot-vscode-extension
- `CLI repo`: https://github.com/devdiv-azure-service-dmitryr/modernize-cli

Each repo maintains its own Java-related skill files.
- https://github.com/devdiv-azure-service-dmitryr/modernize-cli/tree/main/src/GitHub.Copilot.Modernization.Bundle.Generator/Resources/task-skills/java
- https://github.com/devdiv-azure-service-dmitryr/azure-java-migration-copilot-vscode-extension/tree/main/kb

## Problem

Maintaining two independent copies of the same Java-related skills leads to several problems:

- **Duplicated effort**: Every skill change must be applied separately in both repos.
- **Inconsistency risk**: When one repo is updated but the other is not, the two sets of skills silently diverge.
- **No single source of truth**: Without a designated authoritative copy, it is unclear which repo holds the correct version when conflicts arise.

## Solution Proposal

### Basic idea

- Put the skills into one repo (named `skill repo`). Set this repo as the source of truth.
- When the skill repo has updates in the `main` branch, it will trigger GitHub Actions to create PRs in downstream repos (`extension repo` and `CLI repo`) to update the skills.

### Question: How to handle the different skill file paths and front matter

It's known that the extension repo and CLI repo use different skill file paths and front matter. For example, in the scenario `Migrate from Oracle DB to PostgreSQL`, here are the file path and the front matter in the 2 repos:

- Extension repo
    - Path: `kb/database-tasks/oracle-to-postgresql.md`
    - Front matter
        ```md
        ---
        id: oracle-to-postgresql
        title: Migrate Oracle DB to PostgreSQL
        description: Migrate Oracle DB to PostgreSQL
        hierarchy: Database Tasks
        ---
        ```
- CLI repo
    - Path: `src/GitHub.Copilot.Modernization.Bundle.Generator/Resources/task-skills/java/migration-oracle-to-postgresql/SKILL.md`
    - Front matter
        ```md
        ---
        name: migration-oracle-to-postgresql
        description: Migrate from Oracle DB to PostgreSQL
        ---
        ```

### Solution proposal: Not update front matter and use a CSV file to handle the different skill file paths

Here is a proposed solution to this problem:

- In the `skill repo`, the skill files have its own front matter. Example:
    ```md
    ---
    name: Migrate Oracle to PostgreSQL
    description: Migrate Oracle Database to PostgreSQL database in a Java project
    ---
    ```
- Define a special format to record comment, put the comment in the skill file, but the comment will be recognized by sync tool and will not be synced to downstream repos. Here is an example of special format: 
    ```md
    /~~ 
    ~ This is skill comment that will not be synchronized to downstream repos.
    ~/
    ```
    Learned from Java doc, just replace `*` by `~`. Here is an example about Java doc:
    ```java
    /**
    * This is java doc
    */
    ```
- When syncing skills from the skill repo to downstream repos, only update the file content, without changing the file path or front matter.
- Use a CSV file to record the mapping between skill repo file paths and downstream repo file paths. Here is an example:
    ```csv
    skill file path, extension repo kb file path, CLI repo skill file path
    oracle-to-postgresql.md,kb/database-tasks/oracle-to-postgresql.md,src/GitHub.Copilot.Modernization.Bundle.Generator/Resources/task-skills/java/migration-oracle-to-postgresql/SKILL.md
    ```

### About the GitHub Actions

#### GitHub Actions in current repo

- Parameters
    - Skill repo branch. Default is `main`.
    - Extension repo branch. Default is `main`. Set to empty string (`""`) to skip syncing to the Extension repo.
    - CLI repo branch. Default is `main`. Set to empty string (`""`) to skip syncing to the CLI repo.
- Trigger methods
    - Automatically. It will be triggered automatically with default parameters when there are any updates in the `main` branch of the `skill repo`.
    - Manually. Any developer can trigger the pipeline with modified parameters when necessary.

#### GitHub actions in downstream repo

If downstream repos have github actios to test the skill, it can add a parameter: `Skill repo branch`. When the GitHub action starts, it will sync the skills before do other steps. The parameter's default value is empty string, which means it will not sync the skills.

### Example PR

Here is an example PR created automatically by GitHub Actions to upgrade the Spring Boot version in the azure-sdk-for-java repo: https://github.com/Azure/azure-sdk-for-java/pull/48604

### Other ideas
- Create `CONTRIBUTING.md` file in the downstream skill folder about how to update the skill files.
