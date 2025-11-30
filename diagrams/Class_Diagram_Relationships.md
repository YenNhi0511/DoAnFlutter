# Mô Tả Các Mối Quan Hệ Trong Class Diagram

## 1. QUAN HỆ GIỮA CÁC MODELS (Composition/Aggregation)
**Ký hiệu:** Mũi tên đen đậm (solid line, strokeWidth=2)

### 1.1. UserModel → ProjectModel
- **Ký hiệu:** `1` (một User có thể tạo nhiều Project)
- **Loại quan hệ:** One-to-Many (1:N)
- **Mô tả:** Một User có thể sở hữu nhiều Project. Mỗi Project thuộc về một User (ownerId).
- **Hướng:** UserModel → ProjectModel

### 1.2. ProjectModel → BoardModel
- **Ký hiệu:** `1` (một Project có một Board)
- **Loại quan hệ:** One-to-One (1:1)
- **Mô tả:** Mỗi Project có một Board Kanban chính. Board thuộc về Project (projectId).
- **Hướng:** ProjectModel → BoardModel

### 1.3. BoardModel → BoardColumnModel
- **Ký hiệu:** `1` (một Board có nhiều Column)
- **Loại quan hệ:** One-to-Many (1:N)
- **Mô tả:** Một Board có nhiều Column (cột). Mỗi Column thuộc về một Board (boardId).
- **Hướng:** BoardModel → BoardColumnModel

### 1.4. BoardColumnModel → TaskModel
- **Ký hiệu:** `*` (một Column có nhiều Task)
- **Loại quan hệ:** One-to-Many (1:N)
- **Mô tả:** Một Column có thể chứa nhiều Task. Mỗi Task thuộc về một Column (columnId).
- **Hướng:** BoardColumnModel → TaskModel

### 1.5. TaskModel → CommentModel
- **Ký hiệu:** `*` (một Task có nhiều Comment)
- **Loại quan hệ:** One-to-Many (1:N)
- **Mô tả:** Một Task có thể có nhiều Comment. Mỗi Comment thuộc về một Task (taskId).
- **Hướng:** TaskModel → CommentModel

### 1.6. UserModel → TaskModel
- **Ký hiệu:** `?` (một User có thể được gán cho nhiều Task, nhưng không bắt buộc)
- **Loại quan hệ:** One-to-Many (1:N), Optional
- **Mô tả:** Một User có thể được gán làm assignee cho nhiều Task. Task có thể không có assignee (assigneeId có thể null).
- **Hướng:** UserModel → TaskModel

### 1.7. UserModel → CommentModel
- **Ký hiệu:** `1` (một User tạo nhiều Comment)
- **Loại quan hệ:** One-to-Many (1:N)
- **Mô tả:** Một User có thể tạo nhiều Comment. Mỗi Comment được tạo bởi một User (userId).
- **Hướng:** UserModel → CommentModel

---

## 2. QUAN HỆ REPOSITORY → MODEL (Dependency)
**Ký hiệu:** Mũi tên đen nét đứt (dashed line, strokeWidth=1), nhãn "uses"

### 2.1. ProjectRepository → ProjectModel
- **Ký hiệu:** `uses` (dashed arrow)
- **Loại quan hệ:** Dependency
- **Mô tả:** ProjectRepository sử dụng ProjectModel để:
  - Nhận dữ liệu từ database và chuyển đổi thành ProjectModel
  - Gửi dữ liệu ProjectModel lên database
  - Repository không sở hữu Model, chỉ sử dụng nó
- **Hướng:** ProjectRepository → ProjectModel

### 2.2. TaskRepository → TaskModel
- **Ký hiệu:** `uses` (dashed arrow)
- **Loại quan hệ:** Dependency
- **Mô tả:** TaskRepository sử dụng TaskModel để:
  - Nhận dữ liệu từ database và chuyển đổi thành TaskModel
  - Gửi dữ liệu TaskModel lên database
  - Repository không sở hữu Model, chỉ sử dụng nó
- **Hướng:** TaskRepository → TaskModel

### 2.3. TaskRepository → CommentModel
- **Ký hiệu:** `uses` (dashed arrow)
- **Loại quan hệ:** Dependency
- **Mô tả:** TaskRepository sử dụng CommentModel để:
  - Quản lý comments của tasks
  - Nhận dữ liệu comment từ database và chuyển đổi thành CommentModel
  - Gửi dữ liệu CommentModel lên database
- **Hướng:** TaskRepository → CommentModel

---

## 3. QUAN HỆ NOTIFIER → REPOSITORY (Dependency)
**Ký hiệu:** Mũi tên đen nét đứt (dashed line, strokeWidth=1), nhãn "uses"

### 3.1. ProjectNotifier → ProjectRepository
- **Ký hiệu:** `uses` (dashed arrow)
- **Loại quan hệ:** Dependency (Composition trong code: `- repository: ProjectRepository`)
- **Mô tả:** ProjectNotifier sử dụng ProjectRepository để:
  - Gọi các phương thức CRUD của Project
  - Quản lý state của projects trong ứng dụng
  - Notifier chứa repository như một dependency (dependency injection)
- **Hướng:** ProjectNotifier → ProjectRepository

### 3.2. TaskNotifier → TaskRepository
- **Ký hiệu:** `uses` (dashed arrow)
- **Loại quan hệ:** Dependency (Composition trong code: `- repository: TaskRepository`)
- **Mô tả:** TaskNotifier sử dụng TaskRepository để:
  - Gọi các phương thức CRUD của Task
  - Quản lý state của tasks trong ứng dụng
  - Notifier chứa repository như một dependency (dependency injection)
- **Hướng:** TaskNotifier → TaskRepository

---

## TÓM TẮT CÁC LOẠI QUAN HỆ

### Quan hệ Composition/Aggregation (Solid Line - Đậm)
- **Ý nghĩa:** Quan hệ "có" hoặc "thuộc về" giữa các Models
- **Đặc điểm:** Mũi tên đen đậm, có số lượng (1, *, ?)
- **Ví dụ:** Project có Board, Board có Column, Column có Task

### Quan hệ Dependency (Dashed Line - Mảnh)
- **Ý nghĩa:** Quan hệ "sử dụng" hoặc "phụ thuộc"
- **Đặc điểm:** Mũi tên đen nét đứt, có nhãn "uses"
- **Ví dụ:** Repository sử dụng Model, Notifier sử dụng Repository

---

## CHÚ THÍCH VỀ KÝ HIỆU SỐ LƯỢNG

- **`1`**: Một (One) - Bắt buộc
- **`*`**: Nhiều (Many) - Một hoặc nhiều
- **`?`**: Tùy chọn (Optional) - Có thể có hoặc không có

---

## SƠ ĐỒ PHÂN CẤP

```
UserModel
  ├── ProjectModel (1:N)
  │     └── BoardModel (1:1)
  │           └── BoardColumnModel (1:N)
  │                 └── TaskModel (1:N)
  │                       └── CommentModel (1:N)
  ├── TaskModel (?:N) - assignee
  └── CommentModel (1:N) - creator

ProjectRepository → uses → ProjectModel
TaskRepository → uses → TaskModel, CommentModel

ProjectNotifier → uses → ProjectRepository
TaskNotifier → uses → TaskRepository
```

