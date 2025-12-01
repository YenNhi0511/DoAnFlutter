# Chỉ mục các Sơ đồ Kiến trúc Hệ thống - ProjectFlow

## 📋 Danh sách đầy đủ các sơ đồ

### 1. Context Diagram (Level 0 DFD)
**File:** `00_Context_Diagram.drawio`  
**Mô tả:** Sơ đồ bối cảnh hệ thống, thể hiện các external entities và luồng dữ liệu với hệ thống ProjectFlow.

**Các thành phần:**
- User (External Entity)
- Supabase Backend (External Entity)
- Local Storage (External Entity)
- Notification Service (External Entity)
- ProjectFlow System (Central Process)

---

### 2. Data Flow Diagram - Level 1
**File:** `01_DFD_Level1.drawio`  
**Mô tả:** DFD Level 1 phân rã hệ thống thành các process chính.

**Các Process:**
- 1.0 Authentication Management
- 2.0 Project Management
- 3.0 Task Management
- 4.0 Board Management
- 5.0 Data Storage
- 6.0 Real-time Sync
- 7.0 Notification Service

**Data Stores:**
- D1: User Credentials
- D2: Projects
- D3: Tasks
- D4: Local Cache

---

### 3. Data Flow Diagram - Level 2 (Task Management)
**File:** `05_DFD_Level2_Task_Management.drawio`  
**Mô tả:** DFD Level 2 chi tiết cho process Task Management.

**Các Sub-process:**
- 3.1 Create Task
- 3.2 Update Task
- 3.3 Move Task
- 3.4 Assign Task
- 3.5 Add Comment
- 3.6 Validate Task
- 3.7 Save Task
- 3.8 Sync Realtime

---

### 4. Business Process Model (BPMN)
**File:** `02_BPMN_Business_Process.drawio`  
**Mô tả:** Mô hình quy trình nghiệp vụ từ login đến tạo task với real-time sync.

**Các bước:**
1. User Login
2. Validate Credentials
3. Create Project
4. Save to Database
5. Create Board
6. Create Task
7. Real-time Sync

**Gateways:**
- Auth Success/Failed
- Parallel Gateway (Assign Members + Set Deadline)

---

### 5. Use Case Diagram
**File:** `01_Use_Case_Diagram.drawio` (đã có sẵn)  
**Mô tả:** Tất cả use cases và actors trong hệ thống.

**Actors:**
- User
- Team Member
- Project Admin

**Use Cases:** 15 use cases (xem Use Case Specification)

---

### 6. Use Case Specification
**File:** `06_Use_Case_Specification.md`  
**Mô tả:** Chi tiết 15 use cases:
1. UC-001: User Registration
2. UC-002: User Login
3. UC-003: Create Project
4. UC-004: Create Board
5. UC-005: Create Task
6. UC-006: Move Task
7. UC-007: Assign Task
8. UC-008: Add Comment
9. UC-009: Invite Member
10. UC-010: View My Tasks
11. UC-011: Set Task Reminder
12. UC-012: View Calendar
13. UC-013: Upload Attachment
14. UC-014: Real-time Collaboration
15. UC-015: Offline Mode

---

### 7. Class Diagram
**File:** `10_Class_Diagram.drawio` (đã có sẵn)  
**Mô tả:** Cấu trúc classes, relationships, và dependencies.

**Các nhóm:**
- Models: UserModel, ProjectModel, BoardModel, TaskModel, CommentModel
- Repositories: ProjectRepository, TaskRepository
- Notifiers: ProjectNotifier, TaskNotifier

---

### 8. State Machine Diagram
**File:** `03_State_Machine_Diagram.drawio`  
**Mô tả:** Các trạng thái của ứng dụng và transitions.

**States:**
- Not Authenticated
- Authenticating
- Authenticated
- Loading Projects
- Viewing Project
- Managing Tasks
- Offline Mode

**Transitions:** Các luồng chuyển đổi giữa states

---

### 9. Sequence Diagrams

#### 9.1. Create Project (Detailed)
**File:** `07_Sequence_Create_Project_Detailed.drawio`  
**Mô tả:** Luồng chi tiết tạo project từ UI đến database.

#### 9.2. Offline Sync
**File:** `08_Sequence_Offline_Sync.drawio`  
**Mô tả:** Luồng sync dữ liệu khi connection restore.

#### 9.3. Các Sequence Diagrams khác (đã có sẵn):
- `02_Sequence_Login.drawio` - Login flow
- `03_Sequence_Create_Task.drawio` - Create task flow
- `04_Sequence_RealTime_Collaboration.drawio` - Real-time collaboration
- `05_Sequence_Create_Project.drawio` - Create project (simplified)
- `06_Sequence_Move_Task.drawio` - Move task flow
- `07_Sequence_Add_Comment.drawio` - Add comment flow

---

### 10. Deployment Diagram
**File:** `04_Deployment_Diagram.drawio`  
**Mô tả:** Kiến trúc triển khai hệ thống.

**Nodes:**
- Mobile Device (Android/iOS)
- Supabase Cloud
- Supabase Storage

**Components:**
- Flutter Application
- Hive Local Storage
- Supabase Auth
- PostgreSQL Database
- Realtime Service
- Local Notification Service

**Connections:**
- HTTPS/REST API
- WebSocket
- File Upload

---

### 11. Component Diagram
**File:** `09_Component_Diagram.drawio` (đã có sẵn)  
**Mô tả:** Các components và dependencies trong Flutter app.

**Components:**
- UI Components (Screens, Widgets, Theme, Router)
- Business Logic (Providers, Notifiers, Validators)
- Data Layer (Repositories, Models, Services)
- External Services (Supabase, Hive, Notifications)

---

## 📝 Hướng dẫn sử dụng

### Import vào Draw.io:
1. Mở [draw.io](https://app.diagrams.net/)
2. File → Open → Chọn file `.drawio`
3. Hoặc File → Import → Chọn file `.drawio`

### Export:
- File → Export as → PNG/SVG/PDF

### Chỉnh sửa:
- Tất cả các diagram đều có thể chỉnh sửa trong draw.io
- Các element có thể di chuyển, thay đổi màu sắc, thêm/bớt

---

## 🔄 Cập nhật

Khi có thay đổi trong code, cần cập nhật các diagram tương ứng:
- Thêm feature mới → Cập nhật Use Case Diagram
- Thay đổi model → Cập nhật Class Diagram
- Thay đổi flow → Cập nhật Sequence Diagram
- Thay đổi architecture → Cập nhật Component/Deployment Diagram

---

## 📚 Tài liệu tham khảo

- [Draw.io Documentation](https://www.diagrams.net/doc/)
- [UML Notation Guide](https://www.uml-diagrams.org/)
- [BPMN Specification](https://www.bpmn.org/)
- [DFD Notation](https://www.lucidchart.com/pages/data-flow-diagram)

