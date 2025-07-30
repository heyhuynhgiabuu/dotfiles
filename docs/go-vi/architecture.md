# Kiến Trúc Backend

## 1. Kiến Trúc Phân Lớp (Layered Architecture)

| Lớp | Tiếng Việt | Chức Năng |
|-----|------------|-----------|
| Presentation Layer | Lớp Trình Bày | Xử lý HTTP requests/responses |
| Business Layer | Lớp Logic Nghiệp Vụ | Xử lý logic kinh doanh |
| Data Access Layer | Lớp Truy Cập Dữ Liệu | Tương tác với database |
| Infrastructure Layer | Lớp Hạ Tầng | Cấu hình, logging, monitoring |

*   **Khi nào dùng**: Lựa chọn mặc định tốt cho hầu hết các ứng dụng CRUD (Create, Read, Update, Delete) tiêu chuẩn. Rất tốt cho các dự án vừa và nhỏ, nơi sự đơn giản và tốc độ phát triển là quan trọng.
*   **Ưu điểm**: Dễ học, cấu trúc rõ ràng, dễ dàng phân chia công việc.
*   **Nhược điểm**: Có thể trở nên cồng kềnh và khó bảo trì khi logic nghiệp vụ trở nên phức tạp.

## 2. Kiến Trúc Microservices

| Thành Phần | Tiếng Việt | Mô Tả |
|------------|------------|-------|
| API Gateway | Cổng API | Điểm vào duy nhất cho tất cả requests |
| Service Discovery | Khám Phá Dịch Vụ | Tự động tìm và kết nối services |
| Load Balancer | Cân Bằng Tải | Phân phối requests đến nhiều instances |
| Circuit Breaker | Bộ Ngắt Mạch | Ngăn chặn cascade failures (lỗi dây chuyền) |
| Message Queue | Hàng Đợi Tin Nhắn | Giao tiếp bất đồng bộ giữa services |

*   **Khi nào dùng**: Các hệ thống lớn, phức tạp cần khả năng mở rộng (scale) độc lập cho từng chức năng. Phù hợp với các đội ngũ phát triển lớn, làm việc song song trên nhiều dịch vụ.
*   **Ưu điểm**: Khả năng mở rộng linh hoạt, triển khai độc lập, có thể sử dụng các công nghệ khác nhau cho từng dịch vụ.
*   **Nhược điểm**: Phức tạp trong việc triển khai, quản lý và giám sát. Đòi hỏi chi phí vận hành cao hơn.

## 3. CQRS (Command Query Responsibility Segregation)

Tách biệt trách nhiệm giữa việc **ghi (Command)** và **đọc (Query)** dữ liệu.

*   **Command**: Các thao tác làm thay đổi trạng thái hệ thống (CREATE, UPDATE, DELETE).
*   **Query**: Các thao tác truy vấn dữ liệu không làm thay đổi trạng thái.

*   **Khi nào dùng**: Khi hệ thống có yêu cầu về hiệu năng đọc và ghi rất khác nhau. Ví dụ: một trang thương mại điện tử có hàng triệu lượt xem sản phẩm (đọc) nhưng chỉ có vài nghìn lượt đặt hàng (ghi) mỗi giờ.
*   **Ưu điểm**: Tối ưu hóa riêng biệt cho đọc và ghi, cải thiện hiệu năng và khả năng mở rộng.
*   **Nhược điểm**: Tăng độ phức tạp của hệ thống, có thể dẫn đến độ trễ dữ liệu (eventual consistency) giữa write model và read model.

## 4. Event Sourcing

Lưu trữ tất cả các thay đổi của trạng thái ứng dụng như một chuỗi các sự kiện (events). Trạng thái hiện tại được tái tạo bằng cách áp dụng lại tất cả các sự kiện từ đầu.

*   **Khi nào dùng**: Các hệ thống đòi hỏi lịch sử thay đổi đầy đủ (audit log), hoặc cần phân tích hành vi người dùng. Thường được sử dụng cùng với CQRS. Ví dụ: hệ thống ngân hàng, quản lý kho.
*   **Ưu điểm**: Cung cấp lịch sử đầy đủ, dễ dàng gỡ lỗi và tái tạo trạng thái tại một thời điểm bất kỳ.
*   **Nhược điểm**: Rất phức tạp để triển khai đúng. Việc truy vấn trạng thái hiện tại có thể chậm nếu không kết hợp với các pattern khác như Snapshotting.
