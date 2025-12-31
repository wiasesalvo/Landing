---
layout: default
title: Agents
permalink: /docs/agents.html
---

# Agents

PersistenceAI uses an agent system where different agents have specialized roles and capabilities.

## Overview

Agents in PersistenceAI are specialized AI assistants, each designed for specific tasks:

- **General Agent** - Default agent for general coding tasks
- **Code Reviewer** - Specialized in code review and quality
- **Debugger** - Focused on finding and fixing bugs
- **Architect** - Helps with system design and architecture
- **And more...**

## Switching Agents

### Using Keyboard

- **`Tab`** - Cycle to next agent
- **`Shift+Tab`** - Cycle to previous agent

### Using Command

```
/agents
```

This lists all available agents. Select one to switch.

### Using Shortcut

- **`<leader>A`** (default: `Ctrl+X A`) - List agents

## Agent Roles

Each agent has a specific role and set of skills:

### General Agent

The default agent for most coding tasks. Good for:
- General code changes
- Feature implementation
- Code explanations
- Project analysis

### Code Reviewer

Specialized in code review. Good for:
- Code quality checks
- Finding potential issues
- Suggesting improvements
- Security reviews

### Debugger

Focused on debugging. Good for:
- Finding bugs
- Analyzing error messages
- Fixing broken code
- Performance issues

### Architect

Helps with system design. Good for:
- Architecture decisions
- Design patterns
- System structure
- Technical planning

## Subagents

Subagents are specialized agents that can be invoked using `@` mentions for specific tasks. They operate independently and are designed for focused, single-purpose operations.

### Git Committer (`@git-committer`)

A specialized subagent for git operations. Use this agent when you need to commit and push code changes to a git repository.

**Usage:**
```
@git-committer commit these changes with message "Fix alignment issue in editor pane"
```

**What it does:**
- Commits code changes to your local git repository
- Pushes commits to the remote repository (typically `origin`)
- Automatically performs `git pull --rebase` if there are remote changes before pushing
- Writes commit messages with appropriate prefixes and focused on WHY the change was made

**Commit Message Format:**
Commit messages must include a prefix indicating the type of change:
- `docs:` - Documentation changes
- `tui:` - Terminal UI changes
- `core:` - Core functionality changes
- `ci:` - Continuous integration changes
- `ignore:` - Changes in packages/app
- `wip:` - Work in progress

**Special Prefix Rules:**
- For changes in `packages/web` → use `docs:` prefix
- For changes in `packages/app` → use `ignore:` prefix

**Important Notes:**
- Commit messages should be brief since they're used to generate release notes
- Messages should say **WHY** the change was made from an end-user perspective, not **WHAT** was changed
- Avoid generic messages like "improved agent experience" - be very specific about user-facing changes
- The agent automatically handles `git pull --rebase` before pushing
- If merge conflicts occur during rebase, the agent will **not** fix them automatically - it will notify you to resolve them manually
- The agent uses your repository's configured remote (check with `git remote -v`)
- Your repository must be initialized with `git init` and have a remote configured

**Examples:**
```
@git-committer commit and push with message "tui: Add workspace file filtering to @ mention feature"
@git-committer commit these changes with message "docs: Update agent documentation with git-committer details"
@git-committer commit and push with message "core: Fix memory retrieval bottleneck in LanceDBBackend"
```

## Agent Skills

Agents have access to different skills (tools) based on their role:

- **File Operations** - Read, write, modify files
- **Code Analysis** - Analyze codebase structure
- **Search** - Search code and files
- **Execution** - Run commands and scripts
- **And more...**

## Using @ Mentions

You can mention specific agents in your prompts using `@`:

```
@debugger Can you help me fix this error?
```

This ensures the right agent handles your request.

**Available Mentions:**
- Primary agents: `@general`, `@code-reviewer`, `@debugger`, `@architect`
- Subagents: `@git-committer` (and any custom subagents you've configured)

When you type `@` in the prompt, you'll see an autocomplete list of available agents and files in your workspace.

## Agent Configuration

Agents can be configured in your project's `AGENTS.md` file or in the global config.

### Example Agent Config

```json
{
  "agents": [
    {
      "name": "general",
      "role": "General coding assistant",
      "skills": ["file", "search", "execute"]
    }
  ]
}
```

---

For more information, see:
- [Commands](./commands.md) - Agent-related commands
- [Keybinds](./keybinds.md) - Agent switching shortcuts
- [Configuration](./config.md) - Agent configuration
