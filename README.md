# 番茄钟 — 全栈跨平台应用

一个基于 **Flutter** 前端 + **Spring Boot** 后台的全栈项目，包含番茄钟专注计时与企业管理后台功能，支持 Android、iOS、Web、桌面多端运行。

---

## 项目架构

```
┌─────────────────────────────────────────────────┐
│                   前端 (Flutter)                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ Android  │ │   iOS    │ │  Web / Desktop   │ │
│  └────┬─────┘ └────┬─────┘ └────────┬─────────┘ │
│       └────────────┼───────────────┘             │
│              Riverpod 状态管理                     │
│              Dio HTTP 客户端                       │
│              Clean Architecture 分层               │
└──────────────────────┬──────────────────────────┘
                       │ REST API (JSON)
                       │ JWT Bearer Token
┌──────────────────────┴──────────────────────────┐
│                 后台 (Spring Boot 3.x)            │
│  ┌─────────────────────────────────────────────┐ │
│  │  Controller ← Service ← Repository → JPA    │ │
│  │       ↓                        ↓            │ │
│  │  Spring Security         PostgreSQL / H2    │ │
│  │  JWT 认证                Flyway 迁移         │ │
│  └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

---

## 支持端

| 端 | 前端 (Flutter) | 后台 (Spring Boot) |
|---|:---:|:---:|
| **Android** | 原生 APK / AAB | — |
| **iOS** | 原生 IPA | — |
| **Web** | PWA / SPA | — |
| **Windows** | 原生桌面应用 | 可运行 |
| **macOS** | 原生桌面应用 | 可运行 |
| **Linux** | 原生桌面应用 | 可运行 |

> Flutter 一套代码编译到 6 个平台；Spring Boot 后台可部署到任意支持 Java 21 的服务器或容器环境。

---

## 技术栈

### 前端 `flutter_p/`

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | Flutter SDK | ≥3.2.0 |
| 语言 | Dart | 3.x |
| 状态管理 | **flutter_riverpod** | 2.6.x |
| 网络请求 | **Dio** | 5.7.x |
| 本地存储 | shared_preferences | 2.2.x |
| 国际化 | intl | 0.19.x |
| 音频播放 | audioplayers | 5.2.x |
| 推送通知 | flutter_local_notifications | 17.0.x |
| 架构模式 | **Clean Architecture**（Data → Domain → UI） |

### 后台 `java_b/`

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | Spring Boot | 3.3.5 |
| 语言 | Java | 21 LTS |
| 安全 | Spring Security + jjwt | 0.12.x |
| ORM | Spring Data JPA + Hibernate | 6.x |
| 数据库迁移 | Flyway | 10.x |
| API 文档 | Springdoc OpenAPI | 2.6.x |
| 数据库 | PostgreSQL（生产）/ H2（开发） | — |
| 熔断降级 | Resilience4j | 2.2.x |
| 测试 | JUnit 5 + TestContainers | — |
| 架构模式 | **DDD 分层**（Controller → Service → Repository） |

---

## 项目结构

```
first_test/
├── java_b/                                   # Spring Boot 后台
│   ├── pom.xml                               # Maven 配置
│   └── src/main/java/com/enterprise/
│       ├── EnterpriseApplication.java        # 启动类
│       ├── config/                           # Spring 配置
│       │   ├── SecurityConfig.java           #   Security + JWT + CORS
│       │   ├── OpenApiConfig.java            #   Swagger 文档
│       │   └── ResponseAdvice.java           #   统一响应包装
│       ├── common/                           # 通用模块
│       │   ├── exception/                    #   异常处理
│       │   │   ├── ErrorCode.java            #     30+ 错误码枚举
│       │   │   ├── BusinessException.java
│       │   │   └── GlobalExceptionHandler.java
│       │   ├── dto/                          #   通用 DTO
│       │   │   ├── ApiResponse.java          #     统一响应体
│       │   │   └── PageResponse.java         #     分页响应
│       │   └── security/                     #   安全组件
│       │       ├── JwtTokenProvider.java     #     JWT 生成/校验
│       │       ├── JwtAuthenticationFilter.java
│       │       └── UserPrincipal.java
│       └── module/                           # 业务模块
│           ├── auth/                         #   认证（登录/刷新/当前用户）
│           ├── user/                         #   用户管理（CRUD + 角色分配）
│           ├── role/                         #   角色权限 RBAC
│           └── order/                        #   订单管理（状态流转）
│
├── flutter_p/番茄钟/                          # Flutter 前端
│   ├── pubspec.yaml                          # 依赖配置
│   └── lib/
│       ├── main.dart                         # 入口（ProviderScope）
│       ├── app.dart                          # 应用根组件 + 认证网关
│       ├── data/                             # 数据层
│       │   ├── providers.dart                #   Riverpod 依赖注入（服务/仓储）
│       │   ├── services/                     #   服务
│       │   │   ├── api_service.dart          #     Dio HTTP 客户端
│       │   │   ├── auth_storage_service.dart #     Token 本地存储
│       │   │   ├── storage_service.dart      #     通用本地存储
│       │   │   ├── audio_service.dart        #     音频播放
│       │   │   └── notification_service.dart #     推送通知
│       │   └── repositories/                 #   仓储
│       │       ├── auth_repository.dart      #     认证仓储
│       │       ├── timer_repository.dart     #     计时器仓储
│       │       ├── history_repository.dart   #     历史记录仓储
│       │       └── settings_repository.dart  #     设置仓储
│       ├── domain/                           # 领域层
│       │   ├── models/                       #   领域模型
│       │   │   ├── user.dart                 #     用户
│       │   │   ├── auth_tokens.dart          #     令牌对
│       │   │   ├── timer_state.dart          #     计时器状态
│       │   │   ├── timer_settings.dart       #     计时设置
│       │   │   └── pomodoro_session.dart     #     番茄钟会话
│       │   └── use_cases/                    #   用例
│       │       └── complete_pomodoro_use_case.dart
│       └── ui/                               # 界面层
│           ├── core/                         #   主题 & 通用组件
│           │   ├── theme/app_theme.dart
│           │   └── widgets/
│           └── features/                     #   功能模块
│               ├── auth/                     #   认证（登录/注册）
│               │   ├── view_models/
│               │   └── views/
│               ├── timer/                    #   番茄钟计时
│               ├── history/                  #   历史记录
│               └── settings/                 #   设置
│
└── README.md                                 # 本文件
```

---

## 后台 API 端点

### 认证模块 `api/v1/auth`

| 方法 | 路径 | 认证 | 说明 |
|:---:|------|:---:|------|
| POST | `/login` | 公开 | 用户登录，返回 JWT 令牌 |
| POST | `/refresh` | 公开 | 刷新过期的 Access Token |
| GET | `/me` | Bearer | 获取当前登录用户信息 |

### 用户模块 `api/v1/users`

| 方法 | 路径 | 认证 | 说明 |
|:---:|------|:---:|------|
| POST | `/` | 公开 | 用户注册 |
| GET | `/{id}` | Bearer | 查询用户详情 |
| GET | `/` | Bearer (ADMIN) | 分页查询用户列表 |
| PUT | `/{id}` | Bearer | 更新用户信息 |
| DELETE | `/{id}` | Bearer (ADMIN) | 删除用户 |
| PUT | `/{id}/roles` | Bearer (ADMIN) | 分配用户角色 |

### 角色模块 `api/v1/roles`

| 方法 | 路径 | 认证 | 说明 |
|:---:|------|:---:|------|
| POST | `/` | Bearer (ADMIN) | 创建角色 |
| GET | `/{id}` | Bearer (ADMIN) | 查询角色 |
| GET | `/` | Bearer (ADMIN) | 查询全部角色 |
| PUT | `/{id}` | Bearer (ADMIN) | 更新角色权限 |
| DELETE | `/{id}` | Bearer (ADMIN) | 删除角色 |

### 订单模块 `api/v1/orders`

| 方法 | 路径 | 认证 | 说明 |
|:---:|------|:---:|------|
| POST | `/` | Bearer | 创建订单 |
| GET | `/{id}` | Bearer | 查询订单详情 |
| GET | `/` | Bearer | 查询我的订单 |
| GET | `/all` | Bearer (ADMIN) | 查询全部订单 |
| PUT | `/{id}/status` | Bearer (ADMIN) | 更新订单状态 |
| POST | `/{id}/cancel` | Bearer | 取消订单 |

> 统一响应格式：`{ "code": 0, "message": "success", "data": {...}, "timestamp": 1700000000000 }`

---

## 数据库设计

### ER 图

```
users ──────< user_roles >────── roles ──────< role_permissions >────── permissions
  │
  └── orders ──< order_items
```

### 表结构

| 表 | 说明 | 核心字段 |
|----|------|---------|
| `users` | 用户 | id, username, email, password, status |
| `roles` | 角色 | id, name, description |
| `permissions` | 权限 | id, name, resource, action |
| `role_permissions` | 角色-权限 | role_id, permission_id |
| `user_roles` | 用户角色关联 | id, user_id |
| `user_role_mapping` | 用户-角色映射 | user_role_id, role_id |
| `orders` | 订单 | id, order_no, user_id, total_amount, status |
| `order_items` | 订单项 | id, order_id, product_id, quantity, unit_price |

### 订单状态机

```
PENDING → CONFIRMED → SHIPPED → DELIVERED
   │                                  │
   └── CANCELLED                      └── REFUNDED
```

### 预置数据（Flyway 迁移）

- **3 个角色**：ADMIN（全部权限）、USER（基础权限）、MANAGER（管理权限）
- **12 个权限**：user/role/order × CRUD
- **1 个管理员**：admin / admin123（需自行生成 BCrypt 密码）

---

## Flutter 前端功能

### 番茄钟计时
- 25 分钟专注 / 5 分钟短休息 / 15 分钟长休息
- 圆形进度动画 + 实时倒计时
- 每 4 次专注触发长休息
- 暂停、继续、重置、跳过

### 用户认证
- 登录 / 注册 / 自动登录（Token 持久化）
- JWT 过期自动刷新
- 与后台用户系统打通

### 历史记录
- 按天分组的番茄钟记录
- 总次数 / 总时长统计
- 左滑删除、一键清空

### 设置
- 自定义专注/休息时长（5-60 分钟）
- 长休息间隔设置（2-6 次）
- 完成音效开关
- 推送通知开关

---

## 启动方式

### 后台

```bash
# 开发环境（H2 内存数据库，无需安装 PostgreSQL）
cd java_b
./mvnw spring-boot:run

# 生产环境
java -jar target/enterprise-backend-1.0.0.jar --spring.profiles.active=prod
```

启动后访问：
- **Swagger API 文档**：http://localhost:8080/swagger-ui.html
- **H2 控制台**（dev）：http://localhost:8080/h2-console

### 前端

```bash
cd flutter_p/番茄钟
flutter pub get

# Android
flutter run -d android

# iOS（需 macOS + Xcode）
flutter run -d ios

# Web
flutter run -d chrome

# Windows 桌面
flutter run -d windows

# macOS 桌面
flutter run -d macos

# Linux 桌面
flutter run -d linux
```

### 后台 API 地址配置

开发时 Flutter 默认连接 `http://10.0.2.2:8080`（Android 模拟器）。

如需修改，编辑 `lib/data/services/api_service.dart`：

```dart
class ApiService {
  static const String _defaultBaseUrl = 'http://10.0.2.2:8080';
  // Android 真机: http://<电脑IP>:8080
  // iOS 模拟器: http://localhost:8080
  // Web: http://localhost:8080
}
```

---

## 认证流程

```
应用启动 → 检查本地 Token
  ├─ 有 Token → 调用 GET /api/v1/auth/me
  │   ├─ 有效 → 进入主页
  │   └─ 过期 → 调用 POST /api/v1/auth/refresh
  │       ├─ 成功 → 更新 Token → 进入主页
  │       └─ 失败 → 显示登录页
  └─ 无 Token → 显示登录页
      ├─ 登录 → POST /api/v1/auth/login → 保存 Token → 进入主页
      └─ 注册 → POST /api/v1/users → 成功提示 → 返回登录页

主页右上角菜单 → 退出登录 → 清除 Token → 回到登录页
```

---

## 架构亮点

- **Clean Architecture**：Data → Domain → UI 严格分层，依赖倒置
- **Riverpod**：编译时安全的依赖注入，无 context 依赖
- **Dio 拦截器**：统一 JWT 注入 + 响应解包 + 错误处理
- **Spring Security 无状态**：JWT + 方法级权限控制 `@PreAuthorize`
- **Flyway 数据库迁移**：版本化 SQL，支持多环境
- **统一错误码**：30+ 枚举错误码，按模块分段（1xxxx 通用 / 2xxxx 用户 / 3xxxx 角色 / 4xxxx 订单）
- **统一响应格式**：`ApiResponse {code, message, data, timestamp}`
