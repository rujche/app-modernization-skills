# App Modernization Skills

This repo is the **single source of truth** for Java app modernization skill files. Changes here are automatically synced to downstream repos via GitHub Actions.

## Downstream Repos

| Repo | Description |
|------|-------------|
| [Extension repo](https://github.com/devdiv-azure-service-dmitryr/azure-java-migration-copilot-vscode-extension) | VS Code extension for Java migration |
| [CLI repo](https://github.com/devdiv-azure-service-dmitryr/modernize-cli) | Modernize CLI tool |

## Repo Structure

```
skills/                  # Skill files (source of truth)
skill-mapping.csv        # Maps skill files to downstream repo paths
scripts/sync-skills.sh   # Sync script used by GitHub Actions
.github/workflows/       # GitHub Actions workflow
```

## How It Works

1. Edit skill files under `skills/`.
2. On push to `main`, the GitHub Actions workflow reads `skill-mapping.csv` row by row and syncs each skill file to the downstream repos.
3. The workflow creates a PR in each downstream repo with the updated content.

Key behaviors:
- **Front matter is preserved** — each downstream repo keeps its own front matter; only the body content is replaced.
- **Skill comments are stripped** — blocks wrapped in `/~~ ... ~/` are not synced to downstream repos. Use these for internal notes.

## Skill File Format

Each skill file lives in `skills/` with its own front matter:

```md
---
name: Migrate Oracle to PostgreSQL
description: Migrate Oracle Database to PostgreSQL database in a Java project
---

Skill content here...
```

### Skill Comments

Use the `/~~ ... ~/` block to add comments that will **not** be synced downstream:

```md
/~~
~ This comment will not appear in downstream repos.
~/
```

## Skill Mapping

The `skill-mapping.csv` file maps each skill to its path in the downstream repos:

```csv
skill file path,extension repo kb file path,CLI repo skill file path
oracle-to-postgresql.md,kb/database-tasks/oracle-to-postgresql.md,src/.../SKILL.md
```

When adding a new skill, add a row to this CSV with the corresponding downstream paths.

## GitHub Actions

The sync workflow can be triggered:

- **Automatically** — on any push to `main` that modifies `skills/**` or `skill-mapping.csv`.
- **Manually** — via workflow dispatch with the following parameters:
  - **skill_branch** — Skill repo branch to sync from (default: `main`).
  - **extension_repo_branch** — Extension repo branch to sync into (default: `main`). Set to empty string to skip.
  - **cli_repo_branch** — CLI repo branch to sync into (default: `main`). Set to empty string to skip.

### Prerequisites

A repository secret `DOWNSTREAM_REPO_PAT` must be configured with a GitHub Personal Access Token that has write access to both downstream repos.
