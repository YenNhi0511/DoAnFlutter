# Use Case Specification - ProjectFlow

## 1. UC-001: User Registration

**Actor:** User  
**Precondition:** User không có tài khoản  
**Main Flow:**
1. User mở ứng dụng
2. User chọn "Sign Up"
3. User nhập email, password, full name
4. Hệ thống validate dữ liệu
5. Hệ thống tạo tài khoản trong Supabase Auth
6. Hệ thống tạo user record trong database
7. Hệ thống gửi email xác nhận
8. User nhận thông báo đăng ký thành công

**Alternative Flow:**
- 4a. Dữ liệu không hợp lệ → Hiển thị lỗi
- 5a. Email đã tồn tại → Hiển thị lỗi

**Postcondition:** User đã đăng ký thành công

---

## 2. UC-002: User Login

**Actor:** User  
**Precondition:** User đã có tài khoản  
**Main Flow:**
1. User mở ứng dụng
2. User nhập email và password
3. Hệ thống xác thực với Supabase Auth
4. Hệ thống lấy thông tin user từ database
5. Hệ thống lưu session token
6. Hệ thống chuyển đến màn hình Home

**Alternative Flow:**
- 3a. Thông tin đăng nhập sai → Hiển thị lỗi
- 3b. Email chưa xác nhận → Yêu cầu xác nhận email

**Postcondition:** User đã đăng nhập

---

## 3. UC-003: Create Project

**Actor:** Authenticated User  
**Precondition:** User đã đăng nhập  
**Main Flow:**
1. User chọn "Create Project"
2. User nhập tên project, mô tả, chọn màu và icon
3. Hệ thống validate dữ liệu
4. Hệ thống gọi RPC function `create_project_with_owner`
5. Hệ thống tạo project và project_member record
6. Hệ thống cập nhật danh sách projects
7. User thấy project mới trong danh sách

**Alternative Flow:**
- 3a. Tên project trống → Hiển thị lỗi
- 4a. Lỗi database → Hiển thị lỗi và rollback

**Postcondition:** Project mới đã được tạo

---

## 4. UC-004: Create Board

**Actor:** Project Member  
**Precondition:** User là member của project  
**Main Flow:**
1. User mở project
2. User chọn "Create Board"
3. User nhập tên board
4. Hệ thống tạo board trong database
5. Hệ thống tạo các cột mặc định (To Do, In Progress, Done)
6. Hệ thống cập nhật UI với board mới

**Postcondition:** Board mới đã được tạo

---

## 5. UC-005: Create Task

**Actor:** Project Member  
**Precondition:** User đang xem board  
**Main Flow:**
1. User chọn cột và nhấn "Add Task"
2. User nhập title, description, priority, due date
3. User có thể đính kèm file hoặc hình ảnh
4. Hệ thống validate dữ liệu
5. Hệ thống tạo task trong database
6. Hệ thống upload attachments (nếu có)
7. Hệ thống gửi real-time update đến các members
8. Hệ thống lên lịch notification nếu có due date
9. Task xuất hiện trong cột

**Alternative Flow:**
- 4a. Title trống → Hiển thị lỗi
- 6a. Upload thất bại → Lưu task, đánh dấu attachment pending

**Postcondition:** Task mới đã được tạo

---

## 6. UC-006: Move Task

**Actor:** Project Member  
**Precondition:** User đang xem board với tasks  
**Main Flow:**
1. User kéo task từ cột này sang cột khác
2. Hệ thống validate move operation
3. Hệ thống gọi RPC function `move_task_atomic`
4. Hệ thống cập nhật column_id và position
5. Hệ thống gửi real-time update
6. Tất cả users thấy task đã di chuyển

**Alternative Flow:**
- 3a. Concurrent move conflict → Retry với position mới

**Postcondition:** Task đã được di chuyển

---

## 7. UC-007: Assign Task

**Actor:** Project Member  
**Precondition:** User đang xem task detail  
**Main Flow:**
1. User chọn "Assign User"
2. Hệ thống hiển thị danh sách project members
3. User chọn member
4. Hệ thống cập nhật assignee_id của task
5. Hệ thống gửi notification cho assignee
6. Hệ thống gửi real-time update

**Postcondition:** Task đã được gán cho member

---

## 8. UC-008: Add Comment

**Actor:** Project Member  
**Precondition:** User đang xem task detail  
**Main Flow:**
1. User nhập comment
2. User nhấn "Post"
3. Hệ thống tạo comment record
4. Hệ thống gửi real-time update
5. Comment xuất hiện trong danh sách

**Postcondition:** Comment đã được thêm

---

## 9. UC-009: Invite Member

**Actor:** Project Owner/Admin  
**Precondition:** User có quyền invite  
**Main Flow:**
1. User chọn "Invite Members"
2. User nhập email của member
3. Hệ thống kiểm tra user đã tồn tại chưa
4. Nếu chưa: Gửi invitation email
5. Nếu có: Thêm vào project_members
6. Hệ thống gửi notification cho member
7. Member xuất hiện trong danh sách

**Alternative Flow:**
- 3a. Email không hợp lệ → Hiển thị lỗi
- 3b. User đã là member → Hiển thị thông báo

**Postcondition:** Member đã được mời hoặc thêm

---

## 10. UC-010: View My Tasks

**Actor:** Authenticated User  
**Precondition:** User đã đăng nhập  
**Main Flow:**
1. User chọn "My Tasks"
2. Hệ thống load tasks được gán cho user
3. Hệ thống group tasks theo due date
4. User có thể filter theo: All, Assigned, Due Soon, Overdue
5. User có thể search tasks
6. User có thể tap vào task để xem chi tiết

**Postcondition:** User đã xem danh sách tasks

---

## 11. UC-011: Set Task Reminder

**Actor:** Project Member  
**Precondition:** User đang tạo/sửa task  
**Main Flow:**
1. User set due date cho task
2. Hệ thống lên lịch local notification
3. Khi đến thời gian, hệ thống gửi notification
4. User nhận notification trên device

**Postcondition:** Reminder đã được set

---

## 12. UC-012: View Calendar

**Actor:** Authenticated User  
**Precondition:** User đã đăng nhập  
**Main Flow:**
1. User chọn "Calendar"
2. Hệ thống load tất cả tasks có due date
3. Hệ thống hiển thị calendar với tasks
4. User chọn ngày để xem tasks
5. User có thể tap task để xem chi tiết

**Postcondition:** User đã xem calendar

---

## 13. UC-013: Upload Attachment

**Actor:** Project Member  
**Precondition:** User đang tạo/sửa task  
**Main Flow:**
1. User chọn "Attach File"
2. User chọn file từ device (image hoặc document)
3. Hệ thống upload file lên Supabase Storage
4. Hệ thống lấy public URL
5. Hệ thống thêm URL vào task.attachment_urls
6. File xuất hiện trong task

**Alternative Flow:**
- 3a. Upload thất bại → Hiển thị lỗi, queue để retry

**Postcondition:** Attachment đã được upload

---

## 14. UC-014: Real-time Collaboration

**Actor:** Project Members (Multiple)  
**Precondition:** Nhiều users đang xem cùng project/board  
**Main Flow:**
1. User A thực hiện action (create/update/move task)
2. Hệ thống cập nhật database
3. Supabase Realtime trigger change event
4. Supabase broadcast đến tất cả subscribers
5. User B và C nhận update
6. UI của User B và C tự động refresh
7. Tất cả users thấy cùng trạng thái

**Postcondition:** Tất cả users đã sync

---

## 15. UC-015: Offline Mode

**Actor:** Authenticated User  
**Precondition:** User đang sử dụng app  
**Main Flow:**
1. Connection bị mất
2. Hệ thống phát hiện mất kết nối
3. Hệ thống hiển thị offline banner
4. User vẫn có thể xem cached data
5. User có thể tạo/sửa tasks (queue operations)
6. Khi connection restore, hệ thống auto-sync
7. Hệ thống thực hiện queued operations
8. Hệ thống cập nhật UI

**Postcondition:** Data đã được sync

