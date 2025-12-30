---
layout: default
title: Commands
permalink: /docs/commands.html
---

# Commands

PersistenceAI provides a set of commands that you can use to interact with the application. Commands start with `/` and can be accessed via the command palette (`Ctrl+P`) or by typing them directly in the chat input.

## Command Palette

Press `Ctrl+P` (or `<leader>P` if customized) to open the command palette. This shows all available commands with descriptions.

You can also type `/` in the chat input to see command suggestions.

---

## Session Commands

### `/init`

Initialize PersistenceAI for the current project. This analyzes your project and creates an `AGENTS.md` file in the project root.

```
/init
```

> **Tip**: You should commit your project's `AGENTS.md` file to Git. This helps PersistenceAI understand the project structure and coding patterns.

### `/new` or `/clear`

Create a new session.

```
/new
```

Aliases: `/clear`

### `/session`, `/resume`, or `/continue`

List all available sessions so you can resume one.

```
/session
```

Aliases: `/resume`, `/continue`

### `/share`

Share the current session. This creates a link to the conversation that you can share with your team.

```
/share
```

> **Note**: Sessions are not shared by default. You must explicitly share them.

### `/unshare`

Unshare a previously shared session.

```
/unshare
```

Only available if the session is currently shared.

### `/rename`

Rename the current session.

```
/rename
```

### `/copy`

Copy the session transcript to your clipboard.

```
/copy
```

### `/export`

Export the session transcript to a file.

```
/export
```

### `/timeline`

Jump to a specific message in the session timeline.

```
/timeline
```

### `/undo`

Undo the last message and its changes.

```
/undo
```

> **Tip**: You can run `/undo` multiple times to undo multiple changes.

### `/redo`

Redo the last undone message.

```
/redo
```

### `/thinking`

Toggle the visibility of AI thinking/reasoning steps.

```
/thinking
```

---

## Provider & Model Commands

### `/connect`

Connect to an LLM provider. This opens a dialog to select a provider and enter your API key.

```
/connect
```

### `/models`

List all available models from configured providers.

```
/models
```

---

## Agent Commands

### `/agents`

List all available agents.

```
/agents
```

You can also cycle through agents using:
- `Tab` - Next agent
- `Shift+Tab` - Previous agent

---

## MCP Commands

### `/mcp`

Toggle MCP (Model Context Protocol) servers.

```
/mcp
```

---

## UI Commands

### `/theme`

Switch between available themes.

```
/theme
```

You can also use `<leader>T` (default: `Ctrl+X T`) to list themes.

### `/editor`

Open the external editor for the current prompt.

```
/editor
```

### `/status`

Show the current status and system information.

```
/status
```

---

## Help Commands

### `/help`

Show help information.

```
/help
```

### `/commands`

Show all available commands (same as command palette).

```
/commands
```

---

## System Commands

### `/exit`, `/quit`, or `/q`

Exit the application.

```
/exit
```

Aliases: `/quit`, `/q`

---

## Using Commands

### Command Autocomplete

When you type `/` in the chat input, PersistenceAI will show command suggestions. You can:

- Use arrow keys to navigate suggestions
- Press `Enter` to select a command
- Continue typing to filter commands

### Command Arguments

Some commands accept arguments. For example:

```
/rename My New Session Name
```

### Command Shortcuts

Many commands have keyboard shortcuts. See the [Keybinds documentation](./keybinds.md) for a complete list.

---

## Command Reference

| Command | Shortcut | Description |
|---------|----------|-------------|
| `/init` | - | Initialize project |
| `/new` | `<leader>N` | New session |
| `/session` | `<leader>L` | List sessions |
| `/share` | - | Share session |
| `/unshare` | - | Unshare session |
| `/rename` | - | Rename session |
| `/copy` | - | Copy transcript |
| `/export` | `<leader>X` | Export transcript |
| `/timeline` | `<leader>G` | Jump to message |
| `/undo` | `<leader>U` | Undo message |
| `/redo` | `<leader>R` | Redo message |
| `/thinking` | - | Toggle thinking |
| `/connect` | - | Connect provider |
| `/models` | `<leader>M` | List models |
| `/agents` | `<leader>A` | List agents |
| `/mcp` | - | Toggle MCPs |
| `/theme` | `<leader>T` | Switch theme |
| `/editor` | `<leader>E` | Open editor |
| `/status` | `<leader>S` | Show status |
| `/help` | - | Show help |
| `/commands` | `Ctrl+P` | Command palette |
| `/exit` | `Ctrl+C/D` | Exit app |

---

## Tips

1. **Command Palette**: Use `Ctrl+P` to quickly access any command without typing the full command name.

2. **Autocomplete**: Start typing `/` and use autocomplete to find commands quickly.

3. **Keyboard Shortcuts**: Most commands have keyboard shortcuts for faster access.

4. **Command History**: Use arrow keys (`↑/↓`) in the chat input to navigate command history.

---

For more information, see:
- [Keybinds](./keybinds.md) - Keyboard shortcuts
- [Usage](./index.md#usage) - Basic usage guide
- [Agents](./agents.md) - Agent system
