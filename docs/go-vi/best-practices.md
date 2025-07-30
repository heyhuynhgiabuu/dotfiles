# Best Practices & Code Snippets

## 1. Error Handling

Luôn kiểm tra lỗi và sử dụng `fmt.Errorf` với `%w` để bọc (wrap) lỗi, giúp giữ lại context của lỗi gốc.

```go
// Custom error types
type ValidationError struct {
    Field   string
    Message string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("validation error on field %s: %s", e.Field, e.Message)
}

// Error wrapping
func (s *UserService) CreateUser(req CreateUserRequest) error {
    if err := s.validateRequest(req); err != nil {
        // Trả về lỗi validation cụ thể
        return ValidationError{Field: "email", Message: "invalid format"}
    }

    user := req.ToUser()
    if err := s.repo.Create(user); err != nil {
        // Bọc lỗi từ tầng repository để biết nguồn gốc
        return fmt.Errorf("failed to create user in repo: %w", err)
    }

    return nil
}
```

## 2. Configuration Management

Sử dụng struct để quản lý cấu hình và thư viện như `Viper` hoặc `gopkg.in/yaml.v2` để đọc từ file.

```go
// Config struct
type Config struct {
    Server   ServerConfig   `yaml:"server"`
    Database DatabaseConfig `yaml:"database"`
    Redis    RedisConfig    `yaml:"redis"`
}

type ServerConfig struct {
    Port         int           `yaml:"port"`
    ReadTimeout  time.Duration `yaml:"read_timeout"`
    WriteTimeout time.Duration `yaml:"write_timeout"`
}

// Load config từ file
func LoadConfig(path string) (*Config, error) {
    data, err := ioutil.ReadFile(path)
    if err != nil {
        return nil, err
    }

    var config Config
    if err := yaml.Unmarshal(data, &config); err != nil {
        return nil, err
    }

    return &config, nil
}
```

## 3. Graceful Shutdown

Đảm bảo server đóng các kết nối đang hoạt động một cách an toàn trước khi thoát.

```go
func main() {
    // Khởi tạo server
    server := &http.Server{
        Addr:    ":8080",
        Handler: router,
    }

    // Channel để nhận OS signal
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

    // Chạy server trong một goroutine
    go func() {
        if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("Server failed to start: %v", err)
        }
    }()

    log.Println("Server started on :8080")

    // Chờ signal để shutdown
    <-quit
    log.Println("Shutting down server...")

    // Cấp một khoảng thời gian (ví dụ 30s) để xử lý các request còn lại
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := server.Shutdown(ctx); err != nil {
        log.Fatalf("Server forced to shutdown: %v", err)
    }

    log.Println("Server exited gracefully")
}
```
