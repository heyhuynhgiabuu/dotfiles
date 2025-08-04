# Docker Cheatsheet

Đây là danh sách các alias hữu ích cho việc quản lý Docker, được định nghĩa trong `zsh/.zsh/aliases.zsh`.

| Alias | Lệnh đầy đủ | Mô tả |
| ----- | ----------- | ----- |
| `dc` | `docker compose` | Lệnh tắt cho `docker compose` |
| `dcu` | `docker compose up -d` | Khởi chạy các container trong chế độ detached |
| `dcd` | `docker compose down` | Dừng và xóa các container |
| `dps` | `docker ps --format 'table {{.Names}}	{{.Image}}	{{.Status}}	{{.Ports}}'` | Liệt kê các container đang chạy với định dạng bảng |
| `dlogs` | `docker logs -f` | Theo dõi logs của một container cụ thể |
| `dclogs` | `docker compose logs -f` | Theo dõi logs của các service trong compose |
| `dprune` | `docker system prune -af` | Dọn dẹp tất cả các đối tượng Docker không dùng (container, network, image) |
