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
