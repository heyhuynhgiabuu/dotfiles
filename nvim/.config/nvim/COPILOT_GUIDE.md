# 🚀 HƯỚNG DẪN SỬ DỤNG GITHUB COPILOT - NvChad

## 📝 **Phím Tắt Copilot Khi Đang Gõ Code (Insert Mode):**

### **Chấp Nhận Gợi Ý:**
- **Ctrl + L** (Windows/Linux) hoặc **Cmd + L** (Mac)
  - Chấp nhận toàn bộ gợi ý của Copilot
  - Gợi ý sẽ hiện màu xám, nhấn Ctrl+L để chấp nhận

### **Điều Hướng Gợi Ý:**
- **Ctrl + J** → Xem gợi ý tiếp theo
- **Ctrl + K** → Quay lại gợi ý trước đó  
- **Ctrl + O** → Bỏ qua/Dismiss gợi ý hiện tại

## 💬 **Copilot Chat - Phím Tắt với Space (Leader Key):**

### **Trong Normal Mode (không đang gõ):**
- **Space + c + c** → Mở Copilot Chat
- **Space + c + e** → Giải thích code hiện tại
- **Space + c + t** → Tạo test cho code
- **Space + c + r** → Review code
- **Space + c + f** → Refactor code
- **Space + c + d** → Tạo documentation

### **Khi Select Code (Visual Mode):**
1. **Chọn đoạn code** (nhấn `v` rồi di chuyển cursor)
2. **Space + c + e** → Giải thích đoạn code đã chọn
3. **Space + c + t** → Tạo test cho đoạn code đã chọn
4. **Space + c + r** → Review đoạn code đã chọn

## 🔧 **Which-Key Menu:**

### **Xem Tất Cả Phím Tắt:**
- **Nhấn Space** → Đợi 1 giây → Menu which-key sẽ hiện
- **Nhấn Space + c** → Xem tất cả lệnh Copilot
- **Nhấn Space + f** → Xem lệnh File
- **Nhấn Space + l** → Xem lệnh LSP

## 📚 **Ví Dụ Thực Tế:**

### **1. Sử dụng Copilot khi gõ Go:**
```go
func calculateSum(a, b int) int {
    return  // ← Gõ đến đây, Copilot gợi ý: a + b
            // ← Nhấn Ctrl+L để chấp nhận
}
```

### **2. Sử dụng Copilot Chat:**
```
1. Viết function phức tạp
2. Select toàn bộ function (nhấn v, di chuyển cursor)
3. Nhấn Space + c + e → Copilot sẽ giải thích function
```

### **3. Tạo Test với Copilot:**
```
1. Đặt cursor ở function
2. Nhấn Space + c + t → Copilot tạo test tự động
```

## ⚡ **Tips Quan Trọng:**

### **Khi Nào Copilot Hoạt Động:**
- ✅ Trong **Insert Mode** (đang gõ code)
- ✅ Với file có extension: `.go`, `.java`, `.js`, `.py`, etc.
- ✅ Khi có internet connection

### **Nếu Copilot Không Hoạt Động:**
1. Kiểm tra bạn đang ở Insert Mode (nhấn `i` để vào Insert Mode)
2. Kiểm tra file có extension đúng (.go, .java, etc.)
3. Thử nhấn `:Copilot status` để xem trạng thái

### **Màu Sắc Gợi Ý:**
- **Màu xám mờ** = Gợi ý của Copilot (nhấn Ctrl+L để chấp nhận)
- **Màu trắng** = Code bạn đã gõ

## 🎮 **Luồng Làm Việc Điển Hình:**

```
1. Mở NeoVim: nvim test.go
2. Nhấn 'i' để vào Insert Mode
3. Gõ code → Copilot hiện gợi ý màu xám
4. Nhấn Ctrl+L để chấp nhận
5. Nhấn Esc để ra Normal Mode
6. Nhấn Space để xem menu phím tắt
7. Nhấn Space + c + e để giải thích code
```
