# NvChad dotfiles với Enhanced Development

## Cài đặt nhanh

```bash
git clone https://github.com/heyhuynhgiabuu/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash scripts/install.sh
```

## Phím tắt F-key cho Development

### Phím tắt chính (F3-F12)
- **F3**: Toggle NvimTree (file explorer)
- **F4**: Toggle Debug UI (giao diện debug như IntelliJ)
- **F5**: Start/Continue Debug (bắt đầu/tiếp tục debug)
- **F6**: Pause Debug (tạm dừng debug)
- **F7**: Run Test Class (chạy test toàn bộ class)
- **F8**: Run Test Method (chạy test method hiện tại)
- **F9**: Toggle Breakpoint (đặt/bỏ breakpoint)
- **F10**: Step Over (debug: bước qua)
- **F11**: Step Into (debug: bước vào)
- **F12**: Debug Java/Spring Boot (debug ứng dụng Java)

### Debug nâng cao
- `<leader>dv`: Xem giá trị biến
- `<leader>di`: Kiểm tra biến chi tiết
- `<leader>dE`: Đánh giá biểu thức
- `<leader>e`: Mở NvimTree (thay thế cho Neo-tree)
- `<leader>ed`: Hiển thị diagnostics

## Plugin nổi bật

### UI & Navigation
- **NvimTree**: File explorer đơn giản (KISS principle)
- **DAP UI**: Giao diện debug như IntelliJ
- **lualine**: Status line
- **bufferline**: Tab management
- **which-key**: Hướng dẫn phím tắt

### Development Features  
- **JDTLS**: Java Language Server với Spring Boot support
- **DAP**: Debug Adapter Protocol cho debugging
- **nvim-cmp**: Auto-completion nâng cao
- **Treesitter**: Syntax highlighting
- **Mason**: LSP manager

### Git Integration
- **gitsigns**: Git indicators trong editor
- **fugitive**: Git commands

## Tính năng đặc biệt

### Java Development
- **Tự động phát hiện**: Maven/Gradle projects
- **Spring Boot support**: Profile và debugging
- **IntelliJ-like UI**: Debug interface chuyên nghiệp
- **F-key workflow**: Phím tắt logic và dễ nhớ

### KISS Philosophy
- **Đơn giản hóa**: Loại bỏ Neo-tree phức tạp, giữ NvimTree
- **Essential features**: Tập trung vào debugging và development
- **Cross-platform**: Hoạt động trên cả macOS và Linux