# Hướng dẫn sử dụng "plan mode" với agent orchestration

## Mục đích

"Plan mode" giúp bạn lập kế hoạch workflow cho các tác vụ phức tạp, phối hợp nhiều subagent một cách bài bản, minh bạch và dễ kiểm soát.

---

## Khi nào sử dụng "plan mode"?
- Khi gặp một vấn đề lớn, nhiều bước, hoặc cần nhiều agent phối hợp.
- Khi muốn kiểm soát rõ ràng từng bước, dễ dàng review và chỉnh sửa kế hoạch trước khi thực hiện.
- Khi cần tạo ra prompt triển khai để copy-paste vào dev mode.

---

## Quy trình sử dụng "plan mode"

1. **Yêu cầu lập kế hoạch**
   - Đưa ra yêu cầu cụ thể (ví dụ: "Lập kế hoạch kiểm thử bảo mật cho module X").

2. **AI phân tích và chọn template orchestration phù hợp**
   - AI sẽ tự động chọn mẫu từ `docs/agent-orchestration-template.md`.
   - Các mẫu có sẵn: Sequential, Parallel, Conditional, Review/Validation, YAML/Markdown.

3. **AI điền thông tin cụ thể**
   - Thay thế các trường `[Tên workflow]`, `[Tên agent]`, `[Mô tả nhiệm vụ]`, `[Điều kiện]`... bằng thông tin thực tế của task.

4. **Review và xác nhận kế hoạch**
   - Kiểm tra lại các bước, đảm bảo logic hợp lý, không bỏ sót.
   - Có thể chỉnh sửa, bổ sung hoặc kết hợp nhiều mẫu nếu workflow phức tạp.

5. **Copy prompt triển khai**
   - **QUAN TRỌNG**: AI sẽ tự động tạo ra một prompt hoàn chỉnh ở cuối phản hồi.
   - Copy prompt này và paste vào OpenCode ở dev mode để thực hiện.

6. **Triển khai workflow**
   - Chuyển sang dev mode và paste prompt.
   - Theo dõi tiến độ, cập nhật trạng thái từng bước.

---

## Ví dụ đơn giản: Cải thiện README file

### Yêu cầu ban đầu:
```
Tôi muốn cải thiện file README.md của dự án để làm cho nó chuyên nghiệp và dễ hiểu hơn.
```

### Kế hoạch được tạo ra:

**Template được chọn**: Sequential orchestration (vì cần thực hiện theo thứ tự)

```markdown
### Workflow: Cải thiện README

1. docs-writer: Phân tích README hiện tại và đề xuất cấu trúc mới
2. content-marketer: Tối ưu nội dung để dễ đọc và hấp dẫn
3. code-reviewer: Review để đảm bảo tính chính xác kỹ thuật
```

### Prompt triển khai (copy-paste ready):

```
Cải thiện file README.md của dự án dotfiles để làm cho nó chuyên nghiệp và dễ hiểu hơn.

**Yêu cầu cụ thể:**
1. Phân tích README hiện tại và đề xuất cấu trúc mới (docs-writer)
2. Tối ưu nội dung để dễ đọc và hấp dẫn (content-marketer)  
3. Review để đảm bảo tính chính xác kỹ thuật (code-reviewer)

**Tiêu chí chất lượng:**
- README phải có cấu trúc rõ ràng, dễ navigate
- Nội dung ngắn gọn nhưng đầy đủ thông tin
- Bao gồm installation guide, usage examples
- Formatting đẹp mắt với markdown
- Không có lỗi kỹ thuật

**Deliverable:**
- File README.md được cập nhật hoàn toàn
- Giữ nguyên thông tin quan trọng hiện có
- Thêm sections thiếu nếu cần thiết
```

---

## Ví dụ phức tạp hơn: Tạo API với bảo mật

### Yêu cầu ban đầu:
```
Tạo một API endpoint mới cho user authentication với OAuth2 và kiểm thử bảo mật đầy đủ.
```

### Kế hoạch được tạo ra:

**Template được chọn**: Sequential + Review/Validation (kết hợp)

```markdown
### Workflow: Tạo Authentication API

**Giai đoạn 1: Thiết kế và triển khai**
1. backend-architect: Thiết kế API architecture và OAuth2 flow
2. security-auditor: Review thiết kế để đảm bảo best practices
3. golang-pro: Implement API endpoints và OAuth2 integration
4. test-automator: Tạo test suite cho authentication flow

**Giai đoạn 2: Validation và tối ưu**
5. security-auditor: Thực hiện security audit đầy đủ
6. performance-engineer: Kiểm tra và tối ưu performance
7. code-reviewer: Final review cho code quality
```

### Prompt triển khai (copy-paste ready):

```
Tạo một API endpoint mới cho user authentication với OAuth2 và kiểm thử bảo mật đầy đủ.

**Workflow thực hiện:**

**Giai đoạn 1: Thiết kế và triển khai**
1. Thiết kế API architecture và OAuth2 flow (backend-architect)
2. Review thiết kế để đảm bảo best practices (security-auditor) 
3. Implement API endpoints và OAuth2 integration trong Go (golang-pro)
4. Tạo test suite cho authentication flow (test-automator)

**Giai đoạn 2: Validation và tối ưu**  
5. Thực hiện security audit đầy đủ (security-auditor)
6. Kiểm tra và tối ưu performance (performance-engineer)
7. Final review cho code quality (code-reviewer)

**Tech stack:** Go, OAuth2, JWT tokens
**Security requirements:** OWASP compliance, input validation, rate limiting
**Performance targets:** < 200ms response time, support 1000+ concurrent users

**Deliverables:**
- Hoàn chỉnh API endpoints cho authentication
- Comprehensive test suite với >90% coverage  
- Security audit report với tất cả vulnerabilities được fix
- Performance benchmark results
- API documentation
```

---

## Lưu ý quan trọng

### Về việc sử dụng prompt triển khai:
- **Luôn copy toàn bộ prompt** từ section "🚀 Ready-to-Use Implementation Prompt"
- **Paste trực tiếp** vào OpenCode khi ở dev mode  
- **Không cần chỉnh sửa gì thêm** - prompt đã được tối ưu để thực hiện

### Về plan mode:
- Plan mode chỉ **phân tích và lập kế hoạch**, không thực hiện code
- Luôn kiểm tra plan trước khi chuyển sang implementation
- Có thể yêu cầu điều chỉnh plan nếu cần thiết

### Về agent orchestration:
- Có thể kết hợp nhiều mẫu orchestration cho workflow phức tạp
- Nên lưu lại các kế hoạch mẫu để tái sử dụng cho các task tương tự  
- Sau khi hoàn thành, nên review lại để rút kinh nghiệm và tối ưu quy trình

---

## Template ví dụ cho testing

### Prompt thử nghiệm đơn giản:
```
Lập kế hoạch để thêm một function mới vào file utilities trong dự án Go, bao gồm unit test và documentation.
```

### Prompt thử nghiệm phức tạp:
```  
Lập kế hoạch để tạo một microservice hoàn chỉnh cho quản lý user profile, bao gồm database, API, frontend component, và CI/CD pipeline.
```

Sử dụng các prompt này để test plan mode và workflow copy-paste!