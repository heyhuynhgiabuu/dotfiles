# GitHub Copilot Integration

Tích hợp GitHub Copilot vào dotfiles để sử dụng với Neovim và tmux.

## 🚀 Cài đặt nhanh

```bash
# 1. Cập nhật dotfiles với Copilot
./scripts/update-dotfiles-copilot.sh

# 2. Thiết lập Copilot
./scripts/setup-copilot.sh

# 3. Restart tmux và nvim
```

## 📋 Tính năng

### Neovim + Copilot

- **Copilot suggestions**: Gợi ý code trong insert mode
- **Copilot Chat**: Trò chuyện với AI để giải thích, refactor code
- **Multi-language support**: Hỗ trợ nhiều ngôn ngữ lập trình

### tmux Integration

- **Quick access**: Phím tắt nhanh cho Copilot Chat
- **Better clipboard**: Clipboard tích hợp tốt hơn
- **Development workflow**: Layout và binding tối ưu cho dev

## ⌨️ Phím tắt

### Neovim (Insert Mode)

| Phím tắt | Chức năng |
|----------|-----------|
| `Ctrl+L` | Chấp nhận suggestion |
| `Ctrl+J` | Suggestion tiếp theo |
| `Ctrl+K` | Suggestion trước |
| `Ctrl+O` | Dismiss suggestion |

### Neovim (Normal Mode)

| Phím tắt | Chức năng |
|----------|-----------|
| `<leader>cc` | Mở Copilot Chat |
| `<leader>ce` | Giải thích code |
| `<leader>ct` | Generate tests |
| `<leader>cr` | Review code |
| `<leader>cf` | Refactor code |
| `<leader>cd` | Tạo documentation |

### tmux

| Phím tắt | Chức năng |
|----------|-----------|
| `Prefix Ctrl+C` | Mở Copilot Chat trong pane mới |
| `Prefix Ctrl+P` | Kiểm tra Copilot status |
| `Prefix Ctrl+N` | New window với nvim |

## 🔧 Cấu hình

### Copilot Settings

```lua
-- Trong Neovim
vim.g.copilot_enabled = true
vim.g.copilot_filetypes = {
  ["*"] = true,
  ["gitcommit"] = true,
  ["markdown"] = true,
  ["yaml"] = true,
}
```

### tmux Environment

```bash
# Environment variables
COPILOT_EDITOR="nvim"
GITHUB_COPILOT_ENABLED="1"
```

## 🛠️ Commands

### Neovim Commands

```vim
:Copilot auth          " Xác thực Copilot
:Copilot status        " Kiểm tra trạng thái
:Copilot enable        " Bật Copilot
:Copilot disable       " Tắt Copilot

:CopilotChat           " Mở chat
:CopilotChatExplain    " Giải thích code
:CopilotChatTests      " Generate tests
:CopilotChatReview     " Review code
```

### CLI Commands

```bash
gh copilot auth        " Xác thực qua GitHub CLI
gh copilot status      " Kiểm tra subscription
```

## 📝 Workflow Examples

### 1. Code Explanation

1. Select code trong visual mode
2. `<leader>ce` để giải thích

### 2. Generate Tests

1. Mở file cần test
2. `<leader>ct` để tạo tests

### 3. Quick Chat

1. `<leader>cc` trong nvim
2. Hoặc `Prefix Ctrl+C` trong tmux

### 4. Refactoring

1. Select code block
2. `<leader>cf` để refactor

## 🔍 Troubleshooting

### Copilot không hoạt động

```bash
# Kiểm tra authentication
:Copilot status

# Re-authenticate
:Copilot auth

# Kiểm tra GitHub CLI
gh auth status
```

### Plugin không load

```bash
# Trong nvim
:Lazy sync
:Lazy update

# Restart nvim và thử lại
```

### Module not found error

```bash
# Nếu gặp lỗi "module 'plugins.copilot' not found"
# Plugin đã được tích hợp trực tiếp vào custom/plugins.lua
# Chỉ cần restart nvim

# Kiểm tra plugin đã được định nghĩa đúng:
grep -n "github/copilot.vim" ~/.config/nvim/lua/custom/plugins.lua
```

### tmux integration issues

```bash
# Reload tmux config
tmux source-file ~/.tmux.conf

# Install tmux plugins
# Prefix + I
```

## 📚 Resources

- [GitHub Copilot Docs](https://docs.github.com/en/copilot)
- [Copilot.vim](https://github.com/github/copilot.vim)
- [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim)
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank)

## 🤝 Contributing

Nếu bạn có ý tưởng cải thiện tích hợp Copilot, vui lòng tạo issue hoặc PR!

---

**Happy coding with AI! 🤖✨**
