# PersistenceAI Documentation

Welcome to PersistenceAI documentation! PersistenceAI is an open source AI coding agent available as a terminal-based interface, desktop app, or IDE extension.

![PersistenceAI TUI](https://persistence-ai.github.io/Landing/assets/logo.png)

Let's get started.

---

## Prerequisites

To use PersistenceAI in your terminal, you'll need:

1. A modern terminal emulator like:
   - WezTerm, cross-platform
   - Alacritty, cross-platform
   - Ghostty, Linux and macOS
   - Kitty, Linux and macOS
   - Windows Terminal (Windows)
2. API keys for the LLM providers you want to use.

---

## Install

The easiest way to install PersistenceAI is through the install script.

**Linux/macOS:**
```bash
curl -fsSL https://persistence-ai.github.io/Landing/install.sh | bash
```

**Windows (PowerShell):**
```powershell
iwr -useb https://persistence-ai.github.io/Landing/install.ps1 | iex
```

You can also install it with the following commands:

### Using Node.js

**npm:**
```bash
npm install -g persistenceai
```

**Bun:**
```bash
bun install -g persistenceai
```

**pnpm:**
```bash
pnpm install -g persistenceai
```

**Yarn:**
```bash
yarn global add persistenceai
```

### Using Homebrew (macOS and Linux)

```bash
brew install persistenceai
```

### Using Paru (Arch Linux)

```bash
paru -S persistenceai-bin
```

### Windows Package Managers

**Chocolatey:**
```powershell
choco install persistenceai
```

**Scoop:**
```powershell
scoop bucket add extras
scoop install extras/persistenceai
```

You can also grab the binary from the [Releases](https://github.com/Persistence-AI/Landing/releases).

---

## Configure

With PersistenceAI you can use any LLM provider by configuring their API keys.

If you are new to using LLM providers, we recommend using PersistenceAI Zen. It's a curated list of models that have been tested and verified by the PersistenceAI team.

1. Run the `/connect` command in the TUI, select PersistenceAI Zen, and head to the provider's authentication page.
   ```
   /connect
   ```
2. Sign in, add your billing details, and copy your API key.
3. Paste your API key.
   ```
   ┌ API key
   │
   │
   └ enter
   ```

Alternatively, you can select one of the other providers. Learn more in the [Providers documentation](./providers.md).

---

## Initialize

Now that you've configured a provider, you can navigate to a project that you want to work on.

```bash
cd /path/to/project
```

And run PersistenceAI.

```bash
persistenceai
```

Next, initialize PersistenceAI for the project by running the following command.

```
/init
```

This will get PersistenceAI to analyze your project and create an `AGENTS.md` file in the project root.

> **Tip**: You should commit your project's `AGENTS.md` file to Git.
>
> This helps PersistenceAI understand the project structure and the coding patterns used.

---

## Usage

You are now ready to use PersistenceAI to work on your project. Feel free to ask it anything!

If you are new to using an AI coding agent, here are some examples that might help.

---

### Ask questions

You can ask PersistenceAI to explain the codebase to you.

> **Tip**: Use the `@` key to fuzzy search for files in the project.

```
How is authentication handled in @packages/functions/src/api/index.ts
```

This is helpful if there's a part of the codebase that you didn't work on.

---

### Add features

You can ask PersistenceAI to add new features to your project. Though we first recommend asking it to create a plan.

1. **Create a plan**

   PersistenceAI has a _Plan mode_ that disables its ability to make changes and instead suggest _how_ it'll implement the feature.

   Switch to it using the **Tab** key. You'll see an indicator for this in the lower right corner.

   ```
   <TAB>
   ```

   Now let's describe what we want it to do.

   ```
   When a user deletes a note, we'd like to flag it as deleted in the database.
   Then create a screen that shows all the recently deleted notes.
   From this screen, the user can undelete a note or permanently delete it.
   ```

   You want to give PersistenceAI enough details to understand what you want. It helps to talk to it like you are talking to a junior developer on your team.

   > **Tip**: Give PersistenceAI plenty of context and examples to help it understand what you want.

2. **Iterate on the plan**

   Once it gives you a plan, you can give it feedback or add more details.

   ```
   We'd like to design this new screen using a design I've used before.
   [Image #1] Take a look at this image and use it as a reference.
   ```

   > **Tip**: Drag and drop images into the terminal to add them to the prompt.
   >
   > PersistenceAI can scan any images you give it and add them to the prompt. You can do this by dragging and dropping an image into the terminal.

3. **Build the feature**

   Once you feel comfortable with the plan, switch back to _Build mode_ by hitting the **Tab** key again.

   ```
   <TAB>
   ```

   And asking it to make the changes.

   ```
   Sounds good! Go ahead and make the changes.
   ```

---

### Make changes

For more straightforward changes, you can ask PersistenceAI to directly build it without having to review the plan first.

```
We need to add authentication to the /settings route. Take a look at how this is
handled in the /notes route in @packages/functions/src/notes.ts and implement
the same logic in @packages/functions/src/settings.ts
```

You want to make sure you provide a good amount of detail so PersistenceAI makes the right changes.

---

### Undo changes

Let's say you ask PersistenceAI to make some changes.

```
Can you refactor the function in @packages/functions/src/api/index.ts?
```

But you realize that it is not what you wanted. You **can undo** the changes using the `/undo` command.

```
/undo
```

PersistenceAI will now revert the changes you made and show your original message again.

```
Can you refactor the function in @packages/functions/src/api/index.ts?
```

From here you can tweak the prompt and ask PersistenceAI to try again.

> **Tip**: You can run `/undo` multiple times to undo multiple changes.

Or you **can redo** the changes using the `/redo` command.

```
/redo
```

---

## Share

The conversations that you have with PersistenceAI can be shared with your team.

```
/share
```

This will create a link to the current conversation and copy it to your clipboard.

> **Note**: Conversations are not shared by default.

Here's an example conversation with PersistenceAI.

---

## Customize

And that's it! You are now a pro at using PersistenceAI.

To make it your own, we recommend:
- Picking a [theme](./themes.md)
- Customizing [keybinds](./keybinds.md)
- Configuring [code formatters](./formatters.md)
- Creating [custom commands](./commands.md)
- Playing around with the [PersistenceAI config](./config.md)

---

## Next Steps

- [Keybinds](./keybinds.md) - Learn all keyboard shortcuts
- [Commands](./commands.md) - Discover CLI commands
- [Agents](./agents.md) - Understand agent system
- [Providers](./providers.md) - Configure LLM providers
- [Tools](./tools.md) - Available tools and capabilities

---

**Need help?** Check out our [Troubleshooting guide](./troubleshooting.md) or [open an issue](https://github.com/Persistence-AI/.github/issues).
