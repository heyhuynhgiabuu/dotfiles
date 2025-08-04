Đây là một kho lưu trữ dotfiles, không có các lệnh linting, formatting, hay testing tiêu chuẩn cho toàn bộ dự án. Việc kiểm tra được thực hiện thủ công cho từng công cụ.

**Lệnh cài đặt và xác minh chính:**
- `./scripts/install.sh`: Cài đặt và thiết lập môi trường.
- `./scripts/verify-final-correct-layout.sh`: Kiểm tra layout debug.

**Lệnh khởi động môi trường phát triển:**
- `./scripts/tmux-java-layout.sh`: Bắt đầu phiên làm việc cho Java.
- `./scripts/tmux-go-layout.sh`: Bắt đầu phiên làm việc cho Go.

**Các phím nóng gỡ lỗi (Debug Hotkeys):**
- `F9`: Bật/tắt Breakpoint
- `F5`: Bắt đầu/Tiếp tục Debug
- `F10`: Step Over
- `F11`: Step Into
- `F4`: Bật/tắt UI gỡ lỗi
- `F12`: Gỡ lỗi nhanh (Java/Go)