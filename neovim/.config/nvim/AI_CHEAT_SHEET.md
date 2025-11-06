# 🚀 AI-Powered Neovim Setup - Cursor-like Experience

## Overview

This configuration provides a Cursor-like AI coding experience with multiple AI assistants, intelligent auto-completion, and seamless integration between different AI tools.

## 🧠 AI Plugins & Features

### Primary AI Completion - NeoCodeium

**Status**: ✅ Active (Primary)

- **Purpose**: Real-time AI code suggestions as you type
- **Model**: Codeium's proprietary AI model
- **Features**: Context-aware completions, multi-line suggestions

### Alternative AI Completion - Supermaven

**Status**: ✅ Active (Fallback)

- **Purpose**: Backup AI completion when NeoCodeium isn't available
- **Model**: Custom AI model trained on code
- **Features**: Fast inline suggestions

### Advanced AI Assistant - Avante

**Status**: ✅ Active

- **Purpose**: Sophisticated AI coding assistant with chat interface
- **Model**: GPT-4o (OpenAI)
- **Features**: Code generation, editing, refactoring, explanations

### AI Chat Interface - CodeCompanion

**Status**: ✅ Active

- **Purpose**: Interactive AI chat for coding questions and tasks
- **Model**: GPT-4o-mini (OpenAI)
- **Features**: Contextual chat, code explanations, documentation

### GPT Integration - GP.nvim

**Status**: ✅ Active

- **Purpose**: GPT-based code assistance and chat
- **Model**: Configurable (OpenAI API)
- **Features**: Popup and split chat windows

## 🎯 Key Bindings

### Core AI Auto-Completion (Insert Mode)

| Key       | Action               | Description                                |
| --------- | -------------------- | ------------------------------------------ |
| `<Tab>`   | Accept AI suggestion | **Primary** - Accept current AI suggestion |
| `<S-Tab>` | Previous suggestion  | Cycle to previous AI suggestion            |
| `<C-A-a>` | Accept AI suggestion | Alternative key for accepting suggestions  |
| `<C-A-w>` | Accept word          | Accept only the next word of suggestion    |
| `<C-A-l>` | Accept line          | Accept the entire current line suggestion  |
| `<C-A-e>` | Cycle suggestions    | Show next AI suggestion                    |
| `<C-A-r>` | Previous suggestion  | Show previous AI suggestion (alternative)  |
| `<C-A-c>` | Clear suggestions    | Remove all AI suggestions                  |

### AI Assistants (Normal/Visual Mode)

| Key          | Action              | Description                       |
| ------------ | ------------------- | --------------------------------- |
| `<Leader>aa` | Ask AI              | Ask Avante AI about selected code |
| `<Leader>ae` | Edit with AI        | Edit selected code with Avante AI |
| `<Leader>ar` | Refresh suggestions | Refresh Avante AI suggestions     |

### AI Chat Interfaces

| Key          | Action           | Description                       |
| ------------ | ---------------- | --------------------------------- |
| `<Leader>ac` | Open AI Chat     | Open CodeCompanion chat interface |
| `<Leader>ai` | AI Actions       | Show available AI actions         |
| `<Leader>gp` | GPT Chat (popup) | Open GP.nvim chat in popup        |
| `<Leader>gP` | GPT Chat (split) | Open GP.nvim chat in split window |
| `<Leader>gc` | Toggle GPT Chat  | Toggle GP.nvim chat window        |

### AI-Powered Code Tasks

| Key          | Action         | Description                         |
| ------------ | -------------- | ----------------------------------- |
| `<Leader>ad` | Document code  | Generate documentation with AI      |
| `<Leader>at` | Generate tests | Create tests with AI assistance     |
| `<Leader>ax` | Explain code   | Get AI explanation of selected code |

### Smart Text Selection for AI Context

| Key          | Action         | Description                            |
| ------------ | -------------- | -------------------------------------- |
| `<Leader>ao` | Outer block    | Select outer code block for AI context |
| `<Leader>ai` | Inner block    | Select inner code block for AI context |
| `<Leader>af` | Outer function | Select entire function for AI context  |
| `<Leader>aF` | Inner function | Select function body for AI context    |
| `<Leader>ac` | Outer class    | Select entire class for AI context     |
| `<Leader>aC` | Inner class    | Select class body for AI context       |

## ⚙️ Configuration

### Environment Variables Required

```bash
# OpenAI API Key (for Avante and CodeCompanion)
export OPENAI_API_KEY="your-openai-api-key-here"

# Optional: Codeium API Key (NeoCodeium may work without it)
export CODEIUM_API_KEY="your-codeium-api-key-here"
```

### Key Features Enabled

- **Smart Tab Handling**: TAB prioritizes AI suggestions over regular completion
- **Multi-Provider Fallback**: If one AI service fails, others take over
- **Context-Aware Selection**: Use text objects to provide better context to AI
- **Unified Interface**: All AI tools accessible through consistent keybindings

## 🎨 Cursor-like Behaviors

### Auto-Completion Experience

- **Inline Suggestions**: AI suggestions appear as you type (NeoCodeium/Supermaven)
- **Smart Tab Acceptance**: TAB accepts AI suggestions first, falls back to regular completion
- **Context Preservation**: AI understands your current file, project, and recent edits

### AI Assistant Integration

- **Multi-Modal AI**: Different AI tools for different tasks (completion vs chat vs editing)
- **Seamless Switching**: Easy transition between different AI assistants
- **Visual Feedback**: Clear indicators for which AI tool is active

### Enhanced Productivity

- **Quick Actions**: One-key solutions for common coding tasks
- **Context Selection**: Smart text selection for providing relevant context to AI
- **Persistent Sessions**: AI maintains context across your coding session

## 🔧 Troubleshooting

### Common Issues

**AI suggestions not appearing:**

1. Check if NeoCodeium is authenticated: Run `:NeoCodeium auth` in Neovim
2. Verify API keys are set in your environment
3. Restart Neovim to reload plugins

**Tab key not working for AI suggestions:**

1. Ensure NeoCodeium is active and showing suggestions
2. Check that nvim-cmp isn't conflicting (should auto-resolve)
3. Try alternative keybindings (`<C-A-a>`)

**Avante/CodeCompanion not responding:**

1. Verify `OPENAI_API_KEY` environment variable is set
2. Check your internet connection
3. Try with a simpler prompt first

### Performance Tips

- **Disable unused AI providers** in `lua/plugins/ai.lua` if you experience slowdowns
- **Adjust completion delay** in NeoCodeium settings for faster response
- **Use local models** if available (configure in plugin settings)

## 🚀 Advanced Usage

### Customizing AI Behavior

Edit `lua/plugins/ai.lua` to modify:

- AI model selection
- Completion triggers
- Provider priority
- Custom prompts

### Adding New AI Providers

1. Add new plugin to `lua/plugins/ai.lua`
2. Configure appropriate keybindings in `lua/config/keymaps.lua`
3. Update this cheat sheet with new shortcuts

### Workflow Integration

Combine AI tools for maximum productivity:

1. Use NeoCodeium for real-time coding suggestions
2. Select relevant code blocks with mini.ai text objects
3. Use Avante for complex code modifications
4. Leverage CodeCompanion for explanations and documentation

---

**Happy coding with AI assistance!** 🤖✨
