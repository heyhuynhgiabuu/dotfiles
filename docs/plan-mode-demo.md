# Demo Plan Mode - Ví dụ thử nghiệm

## 🎯 Mục đích
File này chứa các ví dụ task đơn giản để bạn thử nghiệm plan mode với workflow copy-paste.

---

## ✅ Ví dụ 1: Task đơn giản - Cải thiện cấu hình Neovim

### Prompt để paste vào plan mode:
```
Lập kế hoạch để cải thiện file cấu hình Neovim của dự án, thêm keybindings mới cho productivity và tối ưu hóa hiệu suất.
```

### Kết quả mong đợi:
- AI sẽ chọn Sequential orchestration
- Sử dụng các agent: code-reviewer, frontend-developer (cho UI/UX), docs-writer
- Tạo ra prompt implementation hoàn chỉnh

---

## ✅ Ví dụ 2: Task trung bình - Tối ưu hóa scripts

### Prompt để paste vào plan mode:
```
Lập kế hoạch để refactor và tối ưu hóa tất cả shell scripts trong thư mục /scripts, thêm error handling và documentation đầy đủ.
```

### Kết quả mong đợi:
- AI sẽ chọn Sequential hoặc Parallel orchestration
- Sử dụng các agent: code-reviewer, debugger, docs-writer
- Workflow bao gồm cả testing và validation

---

## ✅ Ví dụ 3: Task phức tạp - Tích hợp CI/CD

### Prompt để paste vào plan mode:
```
Lập kế hoạch để tạo một CI/CD pipeline hoàn chỉnh cho dự án dotfiles, bao gồm automated testing, security scanning, và deployment automation.
```

### Kết quả mong đợi:
- AI sẽ chọn Sequential + Review/Validation orchestration
- Sử dụng các agent: devops-deployer, security-audit, test-automator, code-reviewer
- Workflow có nhiều giai đoạn với validation checkpoints

---

## 🧪 Hướng dẫn thử nghiệm

### Bước 1: Test plan mode
1. Chuyển OpenCode sang **plan mode**
2. Copy một trong các prompt ví dụ ở trên
3. Paste vào chat và gửi
4. Quan sát AI phân tích và tạo plan

### Bước 2: Test implementation
1. Copy toàn bộ prompt từ section "🚀 Ready-to-Use Implementation Prompt"
2. Chuyển OpenCode sang **dev mode**  
3. Paste prompt implementation
4. Quan sát AI thực hiện workflow

### Bước 3: Verify results
1. Kiểm tra các file được tạo/sửa đổi
2. Test functionality nếu có
3. Review quality của output

---

## 📋 Checklist đánh giá plan mode

### Plan quality:
- [ ] AI chọn đúng orchestration template
- [ ] Workflow logic hợp lý, không redundant
- [ ] Agents được chọn phù hợp với task
- [ ] Có validation/review steps khi cần thiết

### Implementation prompt quality:
- [ ] Prompt đầy đủ context và requirements
- [ ] Có delivery criteria rõ ràng
- [ ] Bao gồm quality standards
- [ ] Ready để paste without editing

### Execution quality:
- [ ] Workflow chạy smooth trong dev mode
- [ ] Agents hoạt động đúng sequence
- [ ] Output meets requirements
- [ ] No manual intervention needed

---

## 🎨 Advanced test cases

### Multi-domain workflow:
```
Lập kế hoạch để tạo một development environment setup script hoàn chỉnh, bao gồm cài đặt tools, cấu hình dotfiles, setup databases, và tạo documentation chi tiết.
```

### Cross-platform workflow:
```
Lập kế hoạch để đảm bảo tất cả cấu hình trong dự án dotfiles hoạt động nhất quán trên cả macOS và Linux, bao gồm testing và troubleshooting guide.
```

### Security-focused workflow:
```
Lập kế hoạch để audit và hardening toàn bộ dự án dotfiles về mặt bảo mật, bao gồm secrets management, permission settings, và security best practices.
```

---

## 💡 Tips để tối đa hóa hiệu quả

1. **Viết prompt rõ ràng**: Đưa ra context đầy đủ về project và requirements
2. **Specify constraints**: Mention tech stack, platform requirements, timeline
3. **Define success criteria**: What does "done" look like?
4. **Request validation**: Ask for review/testing steps in complex workflows
5. **Think in phases**: For big tasks, break into logical phases

---

## 🔄 Feedback loop

Sau khi test, hãy note lại:
- Workflow nào hoạt động tốt nhất?
- Agent nào được sử dụng hiệu quả?
- Prompt implementation có cần điều chỉnh gì?
- Quality của output có đạt expectation?

Dùng feedback này để improve cách viết prompt cho plan mode!