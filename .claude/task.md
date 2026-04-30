## Task 1

项目目前是一个flutter create --platforms=android,ios flutter_starter创建的空flutter项目，我现在需要在这个空项目上，搭建一个通用的项目架子，或者说项目starter，尤其必须用到以下技术栈：

1. Signals，响应式状态管理库，用信号自动追踪依赖并更新 UI。文档地址：https://dartsignals.dev/reference/overview/

2. Flutter Hooks，优雅管理组件状态和生命周期、减少样板代码。文档地址：https://github.com/rrousselGit/flutter_hooks/blob/master/packages/flutter_hooks/resources/translations/zh_cn/README.md

3. get_it，DI依赖注入，对象依赖管理。文档地址: https://pub.dev/packages/get_it

4. fquery，管理和缓存各种异步请求的数据（比如接口、数据库），自动刷新、重试和更新状态，文档地址：https://pub.dev/packages/fquery

5. go_router，管理路由跳转和路由配置的包，文档地址：https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html

6. Freezed，自动生成 Dart/Flutter 模型类的样板代码（构造函数、`copyWith`、`==`、`toJson/fromJson`、模式匹配等），只专注写字段定义，文档地址：https://github.com/rrousselGit/freezed/blob/master/resources/translations/zh_CN/README.md

请帮我搭建这个架子（项目starter）。搭建后，生成一个或多个全面的示例页面，能够将上面的技术栈在这些示例或页面中全部使用起来即可

为了演示fquery等如何处理api，你可以使用一些网上对外开放的且不需要认证的接口，或是一些用于获取网上公共数据的接口


## Task 2

将lib中所有的页面，用 `ducafe_ui_core` 链式扩展替代原生 Flutter 组件，使页面代码更清晰简洁

ducafe_ui_core文档地址：https://pub.dev/packages/ducafe_ui_core