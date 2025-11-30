# Sơ đồ Thiết kế Hệ thống - ProjectFlow

Thư mục này chứa tất cả các sơ đồ thiết kế hệ thống cho ứng dụng ProjectFlow, được tạo bằng Draw.io (XML format).

## 📋 Danh sách Sơ đồ

### 1. Use Case Diagram (`01_Use_Case_Diagram.drawio`)

- **Mô tả**: Mô tả tất cả các use case và actors trong hệ thống
- **Actors**: User, Project Owner, Team Member
- **Use Cases**:
  - Authentication (Đăng nhập, Đăng ký, Quên mật khẩu)
  - Project Management (Tạo, Sửa, Xóa, Lưu trữ dự án)
  - Team Management (Mời, Xóa, Phân quyền thành viên)
  - Board Management (Tạo bảng, Thêm cột, Sắp xếp)
  - Task Management (Tạo, Sửa, Kéo thả, Gán, Deadline, Priority)
  - Collaboration (Bình luận, Đính kèm, Real-time)
  - Notifications (Nhận thông báo, Nhắc nhở)

### 2. Sequence Diagrams

#### 2.1. Login Sequence (`02_Sequence_Login.drawio`)

- **Mô tả**: Luồng đăng nhập sử dụng Supabase Auth
- **Các thành phần**: User → LoginScreen → AuthNotifier → AuthRepository → Supabase Auth
- **Các bước**:
  1. User nhập email/password
  2. LoginScreen gọi AuthNotifier.signIn()
  3. AuthNotifier gọi AuthRepository.signIn()
  4. AuthRepository xác thực với Supabase Auth
  5. Supabase Auth trả về user claims
  6. AuthRepository tạo UserModel từ Supabase user record
  7. Cập nhật state và navigate

#### 2.2. Create Task Sequence (`03_Sequence_Create_Task.drawio`)

- **Mô tả**: Luồng tạo task mới với real-time sync
- **Các thành phần**: User → CreateTaskSheet → TaskNotifier → TaskRepository → Supabase → Realtime Subscribers
- **Các bước**:
  1. User nhập thông tin task
  2. CreateTaskSheet gọi TaskNotifier.createTask()
  3. TaskNotifier gọi TaskRepository.createTask()
  4. TaskRepository INSERT vào Supabase
  5. Supabase broadcast change qua Realtime
  6. Tất cả subscribers nhận update

#### 2.3. Real-time Collaboration (`04_Sequence_RealTime_Collaboration.drawio`)

- **Mô tả**: Luồng real-time collaboration khi User 1 di chuyển task
- **Các thành phần**: User 1 → BoardScreen 1 → Supabase Realtime → PostgreSQL → Supabase Realtime → BoardScreen 2 → User 2
- **Các bước**:
  1. User 1 kéo thả task
  2. BoardScreen gửi moveTask() đến Supabase
  3. Supabase UPDATE database
  4. PostgreSQL trigger change event
  5. Supabase broadcast đến tất cả subscribers
  6. User 2 nhận update và UI tự động refresh

#### 2.4. Create Project Sequence (`05_Sequence_Create_Project.drawio`)

- **Mô tả**: Luồng tạo project mới
- **Các thành phần**: User → CreateProjectSheet → ProjectNotifier → ProjectRepository → Supabase
- **Các bước**:
  1. User nhập thông tin project
  2. CreateProjectSheet gọi ProjectNotifier.createProject()
  3. ProjectNotifier gọi ProjectRepository.createProject()
  4. ProjectRepository INSERT vào Supabase (projects + project_members)
  5. Trả về ProjectModel và cập nhật state

#### 2.5. Move Task Sequence (`08_Sequence_Move_Task.drawio`)

- **Mô tả**: Luồng di chuyển task giữa các cột
- **Các thành phần**: User → KanbanColumn → TaskNotifier → TaskRepository → Supabase
- **Các bước**:
  1. User kéo thả task
  2. KanbanColumn gọi TaskNotifier.moveTask()
  3. TaskNotifier gọi TaskRepository.moveTask()
  4. TaskRepository UPDATE database
  5. Supabase broadcast real-time update
  6. UI tự động cập nhật

#### 2.6. Add Comment Sequence (`09_Sequence_Add_Comment.drawio`)

- **Mô tả**: Luồng thêm bình luận vào task
- **Các thành phần**: User → TaskDetailScreen → TaskNotifier → TaskRepository → Supabase
- **Các bước**:
  1. User nhập bình luận
  2. TaskDetailScreen gọi TaskNotifier.addComment()
  3. TaskNotifier gọi TaskRepository.addComment()
  4. TaskRepository INSERT vào Supabase
  5. Trả về CommentModel và cập nhật UI

### 3. Class Diagram (`10_Class_Diagram.drawio`)

- **Mô tả**: Cấu trúc các class và mối quan hệ
- **Các nhóm**:
  - **Models**: UserModel, ProjectModel, BoardModel, BoardColumnModel, TaskModel, CommentModel
  - **Repositories**: ProjectRepository, TaskRepository
  - **Notifiers**: ProjectNotifier, TaskNotifier
- **Quan hệ**:
  - Project → Board → Column → Task → Comment
  - Repository sử dụng Model
  - Notifier sử dụng Repository
- **📄 Mô tả chi tiết**: Xem file `Class_Diagram_Relationships.md` để hiểu rõ các ký hiệu và mối quan hệ

### 4. Activity Diagram (`11_Activity_Diagram_Task_Flow.drawio`)

- **Mô tả**: Luồng hoạt động tạo task từ đầu đến cuối
- **Các bước**:
  1. Mở Board Screen
  2. Chọn cột
  3. Nhấn "Add Task"
  4. Mở CreateTaskSheet
  5. Nhập thông tin
  6. Validate
  7. Gọi TaskNotifier
  8. Lưu vào Supabase
  9. Broadcast real-time
  10. Cập nhật UI

### 5. Database ERD (`12_Database_ERD.drawio`)

- **Mô tả**: Sơ đồ quan hệ cơ sở dữ liệu
- **Các bảng**:
  - `users` - Thông tin người dùng
  - `projects` - Dự án
  - `project_members` - Thành viên dự án
  - `boards` - Bảng Kanban
  - `board_columns` - Cột trong bảng
  - `tasks` - Task
  - `comments` - Bình luận
  - `labels` - Nhãn
  - `notifications` - Thông báo
  - `activities` - Nhật ký hoạt động
- **Quan hệ**:
  - users 1:N projects (owner)
  - projects N:M users (members)
  - projects 1:N boards
  - boards 1:N board_columns
  - board_columns 1:N tasks
  - tasks 1:N comments
  - projects 1:N labels
  - users 1:N notifications
  - projects 1:N activities

### 6. Architecture Diagram (`13_Architecture_Diagram.drawio`)

- **Mô tả**: Kiến trúc tổng thể của ứng dụng
- **Các tầng**:
  1. **Presentation Layer**: Screens, Widgets, Router, Theme
  2. **Domain Layer**: Providers, State Management
  3. **Data Layer**: Models, Repositories, Error Handling
  4. **External Services**: Supabase, Hive, Notifications
  5. **Core Services**: SupabaseService, LocalStorageService, NotificationService

### 7. Component Diagram (`14_Component_Diagram.drawio`)

- **Mô tả**: Các component và dependencies
- **Các component**:
  - UI Components (Screens, Widgets, Theme, Router)
  - Business Logic (Providers, Notifiers, Validators, Extensions)
  - Data Layer (Models, Repositories, Error Handling)
  - Services (SupabaseService, LocalStorageService, NotificationService)
  - External Services (Supabase, Hive, Notifications)

## 🚀 Cách sử dụng

1. **Mở Draw.io**: Truy cập [app.diagrams.net](https://app.diagrams.net) hoặc mở ứng dụng Draw.io desktop

2. **Import file**:

   - File → Open from → Device
   - Chọn file `.drawio` từ thư mục này

3. **Chỉnh sửa**:

   - Có thể chỉnh sửa, thêm, xóa các phần tử
   - Thay đổi màu sắc, layout theo ý muốn

4. **Export**:
   - File → Export as → PNG/JPG/PDF/SVG
   - Hoặc lưu lại dưới dạng Draw.io format

## 📝 Ghi chú

- Tất cả các sơ đồ được tạo theo chuẩn UML
- Màu sắc được phân loại theo chức năng:
  - 🔵 Xanh dương: UI/Presentation
  - 🟢 Xanh lá: Domain/Business Logic
  - 🟡 Vàng: Data/Models
  - 🟣 Tím: Services
  - 🔴 Đỏ: External/Infrastructure
- Các sơ đồ có thể được mở rộng thêm chi tiết khi cần

## 🔄 Cập nhật

Khi có thay đổi trong hệ thống, cần cập nhật các sơ đồ tương ứng:

- Thêm tính năng mới → Cập nhật Use Case Diagram
- Thay đổi luồng → Cập nhật Sequence/Activity Diagram
- Thay đổi cấu trúc → Cập nhật Class/Component Diagram
- Thay đổi database → Cập nhật ERD
