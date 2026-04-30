# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

基于 Flutter 的 Starter 项目，集成了以下核心技术栈：

- **Signals** (`signals`) — 响应式状态管理，自动追踪依赖并更新 UI
- **Flutter Hooks** (`flutter_hooks`) — 管理组件状态和生命周期，减少样板代码
- **get_it** - di依赖注入
- **fquery** (`fquery` / `fquery_core`) — 异步数据的查询、缓存、自动刷新与重试
- **go_router** — 声明式路由管理
- **Freezed** (`freezed` + `json_serializable`) — 不可变模型类，自动生成 `copyWith`、`==`、`toJson/fromJson` 等


## 常用命令

```bash
# 运行项目（默认设备）
flutter run

# 列出可用模拟器/模拟器
flutter emulators

# 启动指定模拟器（通过 Makefile）
make emu

# 代码分析（lint）
flutter analyze

# 运行所有测试
flutter test

# 运行单个测试
flutter test test/widget_test.dart

# 运行指定名称的测试
flutter test test/widget_test.dart --name "App renders home page"

# Freezed / JSON 代码生成（监听模式）
dart run build_runner watch -d

# Freezed / JSON 代码生成（一次性）
dart run build_runner build --delete-conflicting-outputs

# 构建 APK
flutter build apk

# 构建 iOS
flutter build ios
```

## 项目结构

```
lib/
├── main.dart                        # 入口，包裹 CacheProvider + MaterialApp.router
├── app/
│   ├── router/app_router.dart       # go_router 路由配置
│   └── theme/app_theme.dart        # Material 3 主题（light/dark）
├── core/
│   └── query_cache.dart            # 全局 fquery QueryCache 单例
├── features/
│   ├── home/home_page.dart          # 首页（Tech Stack Demos 入口）
│   ├── signals_demo/signals_page.dart
│   ├── hooks_demo/hooks_page.dart
│   └── fquery_demo/fquery_page.dart
├── models/
│   ├── models.dart                  # barrel export
│   ├── user.dart                    # Freezed 模型（User, Address, Geo, Company）
│   └── post.dart                    # Freezed 模型（Post）
└── services/
    ├── services.dart                # barrel export
    └── api_service.dart             # JSONPlaceholder API 调用（http 包）
```

## 架构要点

### 数据流

1. **ApiService** 使用 `http.Client` 调用 JSONPlaceholder REST API（`https://jsonplaceholder.typicode.com`）
2. **fquery** 在 UI 层包裹 API 调用，自动处理缓存、加载状态、错误状态和重试
3. **Signals** 用于跨组件的响应式状态共享
4. 全局 `queryCache`（`core/query_cache.dart`）通过 `CacheProvider` 在 `main.dart` 中注入

### 模型

所有模型使用 `@freezed` 注解定义，配合 `json_serializable` 自动生成序列化代码。添加新模型后必须运行 `dart run build_runner build --delete-conflicting-outputs`。

### 路由

使用 `go_router`，路由配置集中在 `lib/app/router/app_router.dart`。新增页面需在此注册路由。

## 开发注意事项

- 修改 Freezed 模型后需重新运行 `build_runner` 生成 `.freezed.dart` 和 `.g.dart` 文件
- fquery 查询使用全局 `queryCache`，可通过 `queryCache.invalidate()` 等方式手动失效
- 测试需要包裹 `CacheProvider`，因为 `MyApp` 依赖 fquery 上下文


## UI 开发指南

### 链式扩展模式（强制）

使用 `ducafe_ui_core` 链式扩展替代原生 Flutter 组件：

- 布局: `toColumn()`, `toRow()`, `toStack()`
- 内边距: `paddingAll()`, `paddingHorizontal()`, `paddingVertical()`
- 尺寸: `width()`, `height()`, `expanded()`
- 样式: `onTap()`, `center()`, `alignCenter()`, `safeArea()`

```dart
// ✅ 推荐
[
  _buildHeader(),
  _buildContent(),
  _buildFooter(),
].toColumn()
  .paddingAll(20)
  .scrollable()
  .safeArea();

// ❌ 避免
Column(
  children: [
    _buildHeader(),
    _buildContent(),
    _buildFooter(),
  ],
)
```

**必须优先使用链式扩展来构建 UI**，而不是直接使用 Flutter 原生组件：

- **布局扩展**：`toColumn()`, `toRow()`, `toStack()`
- **内边距扩展**：`paddingAll()`, `paddingHorizontal()`, `paddingVertical()`, `paddingSymmetric()`
- **尺寸扩展**：`width()`, `height()`, `expanded()`, `flex()`
- **约束扩展**：`constrained()`, `maxWidth()`, `maxHeight()`, `minWidth()`, `minHeight()`
- **滚动扩展**：`scrollable()`
- **对齐扩展**：`center()`, `alignCenter()`, `alignRight()`, `alignLeft()`, `alignTop()`, `alignBottom()`
- **安全区域扩展**：`safeArea()`
- **交互扩展**：`onTap()`, `onLongPress()`

**推荐写法**：

```dart
// ✅ 推荐：使用列表字面量 + 链式扩展
[
  _buildHeader(),
  _buildContent(),
  _buildFooter(),
].toColumn()
  .paddingAll(20)
  .scrollable()
  .safeArea();

// ✅ 推荐：单个组件的链式扩展
Widget _buildButton() {
  return XBtn(...)
    .width(double.infinity)
    .paddingHorizontal(16)
    .onTap(() => controller.onTap());
}

// ❌ 不推荐：直接使用原生组件
Column(
  children: [
    _buildHeader(),
    _buildContent(),
    _buildFooter(),
  ],
)
```

**例外情况**（可以使用原生组件）：

- 扩展方式无法表达所需行为/参数
- 为了性能/可读性需要显式原生组件
- 需要非常精确的约束/滚动行为，扩展封装会造成歧义

##### 常用组合模式

- **底部弹层（BottomSheet）**：优先使用 `content.scrollable().constrained(maxHeight: ...)` 组合
- **列表布局**：使用 `[...].toColumn()` 或 `[...].toRow()` 配合链式扩展
- **条件渲染**：在列表字面量中使用 `if` 条件，如 `if (condition) Widget(...)`

##### 组件和资源使用规范

**组件宽度规范**

**组件宽度应自适应，避免设置固定宽度**：

- 优先使用 `width(double.infinity)` 让组件占满父容器宽度
- 使用 `expanded()` 或 `flex()` 在 Row/Column 中自适应
- 使用 `constrained()` 设置最大/最小宽度约束，而非固定宽度
- 仅在特殊场景（如固定尺寸图标、头像等）使用固定宽度

**推荐写法**：

```dart
// ✅ 推荐：使用 double.infinity 自适应宽度
XBtn(...)
  .width(double.infinity)
  .paddingHorizontal(16);

// ✅ 推荐：使用 expanded() 在 Row 中自适应
[
  _buildLeft(),
  _buildRight().expanded(),
].toRow();

// ✅ 推荐：使用 constrained() 设置最大宽度
_buildContent()
  .constrained(maxWidth: 400)
  .center();

// ❌ 不推荐：使用固定宽度
Container(
  width: 375,
  child: _buildContent(),
)
```
