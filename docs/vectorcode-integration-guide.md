# Hướng dẫn tích hợp VectorCode với Neovim và OpenCode

> **Phiên bản: 2025-08**  
> Tham khảo tài liệu gốc: https://github.com/Davidyz/VectorCode

---

## 1. Yêu cầu trước khi cài đặt

- **Hệ điều hành:** macOS hoặc Linux
- **Python:** >= 3.8 (kiểm tra bằng `python3 --version` hoặc `python --version`)
- **pip:** đã cài đặt (kiểm tra bằng `pip3 --version` hoặc `pip --version`)
- **Neovim:** >= 0.9 (kiểm tra bằng `nvim --version`)
- **Đã cài plugin manager cho Neovim** (vd: lazy.nvim, packer.nvim, v.v.)
- **Git:** đã cài đặt (kiểm tra bằng `git --version`)

### Kiểm tra nhanh
```sh
# Kiểm tra Python (thử cả hai lệnh)
python3 --version || python --version
pip3 --version || pip --version
nvim --version
git --version
```
Nếu thiếu, hãy cài đặt theo hướng dẫn hệ điều hành của bạn.

---

## 2. Cài đặt VectorCode CLI

### Qua pip (khuyến nghị)
```sh
# Sử dụng pip3 nếu có cả python2 và python3
pip3 install --upgrade vectorcode
# Hoặc nếu chỉ có python3
pip install --upgrade vectorcode
```
- Tham khảo: [CLI docs](https://github.com/Davidyz/VectorCode/blob/main/docs/cli.md)

### Xác minh cài đặt
```sh
vectorcode --help
```
Nếu hiện menu trợ giúp là thành công.

### (Tùy chọn) Cài đặt từ source
- Xem hướng dẫn chi tiết: [CLI docs](https://github.com/Davidyz/VectorCode/blob/main/docs/cli.md)

---

## 3. Khởi tạo và index repo

Tại thư mục dự án cần index:
```sh
vectorcode init
vectorcode index
```
- Sau khi chạy, sẽ xuất hiện thư mục `.vectorcode/` trong repo.
- Tham khảo: [CLI docs](https://github.com/Davidyz/VectorCode/blob/main/docs/cli.md)

---

## 4. Cài đặt plugin VectorCode cho Neovim

### Với lazy.nvim (Lua)
```lua
{
  "Davidyz/VectorCode",
  config = function()
    require("vectorcode").setup({})
  end,
}
```

### Với packer.nvim
```lua
use {
  "Davidyz/VectorCode",
  config = function()
    require("vectorcode").setup({})
  end,
}
```

- Tham khảo: [Neovim plugin docs](https://github.com/Davidyz/VectorCode/blob/main/docs/neovim/README.md)

### Xác minh plugin
- Mở Neovim, chạy `:lua print(require('vectorcode').status())` hoặc kiểm tra không báo lỗi khi khởi động.

---

## 5. Tích hợp với OpenCode

### Cấu hình cơ bản
- VectorCode cung cấp context thông qua API Lua trong Neovim
- OpenCode có thể truy cập context này để cải thiện hiểu biết về codebase

### Kiểm tra kết nối
```lua
-- Trong Neovim, chạy lệnh sau để kiểm tra API
:lua print(vim.inspect(require('vectorcode').get_context()))
```

### Tài liệu tham khảo
- [VectorCode Lua API](https://github.com/Davidyz/VectorCode/blob/main/docs/neovim/api_references.md)
- [OpenCode Integration](https://github.com/Davidyz/VectorCode/wiki/OpenCode-Integration)

---

## 6. Checklist xác minh thủ công

### Cài đặt CLI
- [ ] `vectorcode --help` hiển thị menu trợ giúp đầy đủ
- [ ] `vectorcode --version` hiển thị phiên bản hiện tại

### Index dự án
- [ ] `vectorcode init` tạo file `.vectorcode/config.toml`
- [ ] `vectorcode index` tạo thư mục `.vectorcode/` với các file index
- [ ] Kiểm tra kích thước index hợp lý (không quá lớn)

### Plugin Neovim
- [ ] Khởi động Neovim không có lỗi VectorCode
- [ ] `:lua require('vectorcode')` không báo lỗi
- [ ] `:lua print(require('vectorcode').status())` trả về status

### Tích hợp (tùy chọn)
- [ ] API Lua trả về context khi gọi `get_context()`
- [ ] OpenCode nhận được context từ VectorCode

### Gỡ cài đặt (nếu cần)
- [ ] `pip uninstall vectorcode` gỡ CLI thành công
- [ ] Xóa plugin khỏi config Neovim
- [ ] Xóa thư mục `.vectorcode/` khỏi dự án

---

## 7. Mẹo xử lý lỗi & tham khảo

- Nếu lỗi pip, thử thêm `--user` hoặc `--break-system-packages` (Python 3.11+) hoặc kiểm tra quyền truy cập Python/pip.
- Nếu plugin Neovim không nhận, kiểm tra lại tên plugin và cấu hình plugin manager.
- Nếu index repo lỗi, kiểm tra quyền ghi thư mục hoặc trạng thái git.
- Tham khảo thêm:
  - [CLI docs](https://github.com/Davidyz/VectorCode/blob/main/docs/cli.md)
  - [Neovim plugin docs](https://github.com/Davidyz/VectorCode/blob/main/docs/neovim/README.md)
  - [Wiki VectorCode](https://github.com/Davidyz/VectorCode/wiki)

---

**Hướng dẫn này tuân thủ nguyên tắc KISS, không thêm phụ thuộc không cần thiết, không tự động hóa ngoài pip, và có thể hoàn tác dễ dàng.**
