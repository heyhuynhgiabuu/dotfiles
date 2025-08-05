### [Pattern: Tích hợp VectorCode với Neovim và OpenCode]

**Mô tả:**
Hướng dẫn từng bước cài đặt và tích hợp VectorCode (index mã nguồn, cung cấp context cho LLM) với Neovim và OpenCode, đảm bảo đa nền tảng, tối giản, rollback dễ dàng, checklist xác minh thủ công rõ ràng.

**Checklist chính:**
- [x] Kiểm tra Python, pip, Neovim, git
- [x] Cài VectorCode CLI qua pip
- [x] Khởi tạo và index repo với vectorcode init/index
- [x] Thêm plugin VectorCode vào cấu hình Neovim (lazy.nvim/packer)
- [x] Kiểm tra plugin nạp thành công, gọi API trả về kết quả
- [x] Tích hợp context VectorCode vào OpenCode/plugin AI
- [x] Checklist xác minh thủ công từng bước

**Mẹo thực tế:**
- Ưu tiên pip, không tự động hóa ngoài pip nếu chưa được phép
- Nếu lỗi pip, thử thêm --user hoặc kiểm tra quyền
- Nếu plugin lỗi, kiểm tra lại tên và cấu hình plugin manager
- Có thể rollback dễ dàng bằng cách xóa plugin và thư mục .vectorcode/

**Tham khảo:**
- https://github.com/Davidyz/VectorCode
- https://github.com/Davidyz/VectorCode/blob/main/docs/cli.md
- https://github.com/Davidyz/VectorCode/blob/main/docs/neovim/README.md

**Liên quan:**
- File: docs/vectorcode-integration-guide.md
- Chủ đề: AI context injection, codebase indexing, Neovim, OpenCode
