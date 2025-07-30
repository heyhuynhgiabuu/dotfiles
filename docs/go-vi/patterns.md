# Mẫu Thiết Kế (Design Patterns)

## 1. Repository Pattern

**Mục đích**: Tách biệt logic truy cập dữ liệu ra khỏi logic nghiệp vụ.

```go
// Giao diện Repository - Interface định nghĩa các phương thức truy cập dữ liệu
type UserRepository interface {
    Create(user *User) error          // Tạo người dùng mới
    GetByID(id string) (*User, error) // Lấy người dùng theo ID
    Update(user *User) error          // Cập nhật thông tin người dùng
    Delete(id string) error           // Xóa người dùng
}

// Triển khai Repository với MySQL
type MySQLUserRepository struct {
    db *sql.DB // Kết nối database
}

// Tạo người dùng mới trong database
func (r *MySQLUserRepository) Create(user *User) error {
    query := "INSERT INTO users (name, email) VALUES (?, ?)"
    _, err := r.db.Exec(query, user.Name, user.Email)
    return err
}
```

## 2. Service Pattern

**Mục đích**: Đóng gói logic nghiệp vụ của ứng dụng.

```go
// Dịch vụ xử lý logic nghiệp vụ
type UserService struct {
    repo UserRepository // Dependency injection
}

// Đăng ký người dùng mới với validation
func (s *UserService) RegisterUser(name, email string) error {
    // Kiểm tra email đã tồn tại chưa (logic nghiệp vụ)
    if s.isEmailExists(email) {
        return errors.New("email đã được sử dụng")
    }
    
    // Tạo đối tượng User mới
    user := &User{
        Name:  name,
        Email: email,
    }
    
    // Lưu vào database thông qua repository
    return s.repo.Create(user)
}
```

## 3. Middleware Pattern (cho Web)

**Mục đích**: Thực thi các hành động trước hoặc sau một HTTP request handler.

```go
// Middleware xác thực JWT token
func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        // Lấy token từ header Authorization
        token := c.GetHeader("Authorization")
        
        if token == "" {
            c.JSON(401, gin.H{"error": "Token không được cung cấp"})
            c.Abort() // Dừng xử lý request
            return
        }
        
        // Xác thực token (logic xác thực ở đây)
        if !isValidToken(token) {
            c.JSON(401, gin.H{"error": "Token không hợp lệ"})
            c.Abort()
            return
        }
        
        c.Next() // Tiếp tục xử lý các handler tiếp theo
    }
}
```
