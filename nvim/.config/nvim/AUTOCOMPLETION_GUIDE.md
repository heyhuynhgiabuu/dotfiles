# 🎯 HƯỚNG DẪN AUTOCOMPLETION - NeoVim

## 📝 **BƯỚC 1: Mở File Demo**
```bash
cd /Users/killerkidbo/dotfiles/nvim/.config/nvim
nvim demo_autocompletion.go
```

## 📝 **BƯỚC 2: Vào Insert Mode**
- Nhấn phím `i` 
- Sẽ thấy `-- INSERT --` ở dưới màn hình

## 📝 **BƯỚC 3: Test Autocompletion Cơ Bản**

### **Test fmt package:**
1. Gõ: `fmt.`
2. Menu autocompletion sẽ hiện với các options:
   - `Print`
   - `Println` 
   - `Printf`
   - `Sprintf`
   - etc.

### **Điều khiển menu:**
- `Ctrl + n` hoặc `↓` = Di chuyển xuống
- `Ctrl + p` hoặc `↑` = Di chuyển lên  
- `Tab` hoặc `Enter` = Chọn item
- `Esc` = Đóng menu

## 📝 **BƯỚC 4: Test Go Modules (Như Trong Hình)**

### **Tạo comment go mod:**
1. Gõ: `// go mod`
2. Hoặc gõ: `go mod`
3. Sẽ hiện menu như trong hình:
   - `🔴 mod` (Module maintenance)
   - `💜 mod` (Other mod suggestions)

## 📝 **BƯỚC 5: Test Struct Autocompletion**

### **Tạo struct:**
```go
type Person struct {
    Name string
    Age  int
}
```

### **Test field completion:**
1. Gõ: `p := Person{`
2. Menu sẽ hiện với:
   - `Name:`
   - `Age:`

## 📝 **BƯỚC 6: Test Import Autocompletion**

### **Trong import block:**
1. Gõ: `"net/`
2. Sẽ hiện:
   - `net/http`
   - `net/url`
   - `net/mail`
   - etc.

## ⚡ **Phím Tắt Quan Trọng:**

| Phím | Chức năng |
|------|-----------|
| `i` | Vào Insert Mode |
| `Esc` | Thoát Insert Mode |
| `Ctrl + Space` | Trigger completion manually |
| `Tab` / `Enter` | Chấp nhận suggestion |
| `Ctrl + n` | Next suggestion |
| `Ctrl + p` | Previous suggestion |
| `Ctrl + e` | Close completion menu |

## 🔧 **Nếu Autocompletion Không Hoạt Động:**

1. **Kiểm tra bạn đang ở Insert Mode:**
   - Nhấn `i` để vào Insert Mode
   - Thấy `-- INSERT --` ở dưới

2. **Kiểm tra LSP hoạt động:**
   ```
   :LspInfo
   ```

3. **Trigger completion thủ công:**
   - Nhấn `Ctrl + Space`

4. **Restart LSP:**
   ```
   :LspRestart
   ```

## 🎯 **Demo Commands để Test:**

```go
// Test 1: fmt package
fmt.

// Test 2: Go modules  
go mod

// Test 3: Struct fields
p := Person{

// Test 4: Import packages
import "net/

// Test 5: Method calls
http.

// Test 6: Variables
var name str
```

## 💡 **Tips:**
- Autocompletion sẽ hiện khi bạn gõ `.` sau package/struct
- Menu sẽ filter theo những gì bạn gõ
- Copilot suggestions (màu xám) khác với LSP completion (menu popup)
- File phải có extension `.go` để Go LSP hoạt động
